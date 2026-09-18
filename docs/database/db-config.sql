-- =============================================================
-- OnTrain Database Security & Automation Config
-- Run order: 1) Grants → 2) RLS Policies → 3) RPCs → 4) Triggers → 5) Seeds
-- =============================================================

-- =============================================================
-- 1) RESTORE SCHEMA USAGE (prerequisite for all table access)
-- =============================================================
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

-- =============================================================
-- 2) TABLE GRANTS (scoped, not blanket — RLS is the real gatekeeper)
-- =============================================================

-- Public browsing (anon) + authenticated
GRANT SELECT ON profiles, pt_profiles, service_packages,
      specialties, pt_specialties, pt_certifications, pt_gallery,
      time_slots, platform_settings TO anon, authenticated;

-- profiles: own insert/update (via RLS policies)
GRANT INSERT, UPDATE ON profiles TO authenticated;

-- pt_profiles / service_packages / specialty tables: PT manages own
GRANT INSERT, UPDATE, DELETE ON pt_profiles, service_packages,
      specialties, pt_specialties, pt_certifications, pt_gallery
      TO authenticated;

-- bookings: both parties read + client insert / both update (via RLS)
GRANT SELECT ON bookings, payments TO anon, authenticated;
GRANT INSERT, UPDATE ON bookings TO authenticated;

-- payments: client inserts; both parties read (journal writes stay server-side)
GRANT INSERT ON payments TO authenticated;

-- earnings & payouts: PT self-service only
GRANT SELECT ON pt_earnings TO authenticated;
GRANT SELECT, INSERT ON payouts TO authenticated;

-- reviews / favorites / notifications / disputes
GRANT SELECT ON reviews TO anon, authenticated;
GRANT INSERT, UPDATE ON reviews TO authenticated;
GRANT INSERT, SELECT, UPDATE, DELETE ON favorites TO authenticated;
GRANT SELECT, UPDATE ON notifications TO authenticated;
GRANT SELECT, INSERT ON disputes TO authenticated;

-- conversations / messages (any message-based feature later)
GRANT SELECT, INSERT, UPDATE ON conversations, messages TO authenticated;

-- moderation is admin-only: NOTHING granted to public roles

-- Future tables keep these grants by default
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO anon;

-- =============================================================
-- 3) RLS POLICIES (row-level filters)
-- =============================================================

-- profiles: public read (non-deleted), own insert, own update
DROP POLICY IF EXISTS "Public profiles read" ON profiles;
CREATE POLICY "Public profiles read"
  ON profiles FOR SELECT
  USING (deleted_at IS NULL);

DROP POLICY IF EXISTS "Users update own profile" ON profiles;
CREATE POLICY "Users update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users insert own profile" ON profiles;
CREATE POLICY "Users insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- pt_profiles: active public read, PT manage own
DROP POLICY IF EXISTS "Active PT profiles public read" ON pt_profiles;
CREATE POLICY "Active PT profiles public read"
  ON pt_profiles FOR SELECT
  USING (status = 'active');

DROP POLICY IF EXISTS "PT manage own profile" ON pt_profiles;
CREATE POLICY "PT manage own profile"
  ON pt_profiles FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- service_packages: active public read, PT manage own
DROP POLICY IF EXISTS "Active packages public read" ON service_packages;
CREATE POLICY "Active packages public read"
  ON service_packages FOR SELECT
  USING (status = 'active');

DROP POLICY IF EXISTS "PT manage own packages" ON service_packages;
CREATE POLICY "PT manage own packages"
  ON service_packages FOR ALL
  USING (auth.uid() = pt_id)
  WITH CHECK (auth.uid() = pt_id);

-- bookings: client insert own, both parties select own, clients cancel only, PTs full lifecycle
DROP POLICY IF EXISTS "Users insert own bookings" ON bookings;
CREATE POLICY "Users insert own bookings"
  ON bookings FOR INSERT
  WITH CHECK (auth.uid() = client_id);

DROP POLICY IF EXISTS "Clients select own bookings" ON bookings;
CREATE POLICY "Clients select own bookings"
  ON bookings FOR SELECT
  USING (auth.uid() = client_id);

DROP POLICY IF EXISTS "PTs select own bookings" ON bookings;
CREATE POLICY "PTs select own bookings"
  ON bookings FOR SELECT
  USING (auth.uid() = pt_id);

DROP POLICY IF EXISTS "Clients cancel own bookings" ON bookings;
CREATE POLICY "Clients cancel own bookings"
  ON bookings FOR UPDATE
  USING (auth.uid() = client_id)
  WITH CHECK (
    auth.uid() = client_id
    AND status IN ('cancelled_by_client', 'refunded', 'disputed')
  );

DROP POLICY IF EXISTS "PTs update own bookings" ON bookings;
CREATE POLICY "PTs update own bookings"
  ON bookings FOR UPDATE
  USING (auth.uid() = pt_id)
  WITH CHECK (auth.uid() = pt_id);

-- payments: client insert own, booking parties read
DROP POLICY IF EXISTS "Clients insert own payments" ON payments;
CREATE POLICY "Clients insert own payments"
  ON payments FOR INSERT
  WITH CHECK (auth.uid() = client_id);

DROP POLICY IF EXISTS "Booking parties read payments" ON payments;
CREATE POLICY "Booking parties read payments"
  ON payments FOR SELECT
  USING (
    auth.uid() = client_id OR
    auth.uid() IN (SELECT pt_id FROM bookings WHERE id = booking_id)
  );

-- pt_earnings: PT read own
DROP POLICY IF EXISTS "PT read own earnings" ON pt_earnings;
CREATE POLICY "PT read own earnings"
  ON pt_earnings FOR SELECT
  USING (auth.uid() = pt_id);

-- platform_settings: public read is_public
DROP POLICY IF EXISTS "Public settings read" ON platform_settings;
CREATE POLICY "Public settings read"
  ON platform_settings FOR SELECT
  USING (is_public = true);

-- reviews: public read approved, client insert own, PT respond own
DROP POLICY IF EXISTS "Public read approved reviews" ON reviews;
CREATE POLICY "Public read approved reviews"
  ON reviews FOR SELECT
  USING (visibility = 'public' AND moderation_status = 'approved');

DROP POLICY IF EXISTS "Users insert own review" ON reviews;
CREATE POLICY "Users insert own review"
  ON reviews FOR INSERT
  WITH CHECK (auth.uid() = client_id);

DROP POLICY IF EXISTS "PT respond to own reviews" ON reviews;
CREATE POLICY "PT respond to own reviews"
  ON reviews FOR UPDATE
  USING (auth.uid() = pt_id);

-- favorites: users manage own
DROP POLICY IF EXISTS "Users manage own favorites" ON favorites;
CREATE POLICY "Users manage own favorites"
  ON favorites FOR ALL
  USING (auth.uid() = client_id)
  WITH CHECK (auth.uid() = client_id);

-- notifications: users read/update own
DROP POLICY IF EXISTS "Users read own notifications" ON notifications;
CREATE POLICY "Users read own notifications"
  ON notifications FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users update own notifications" ON notifications;
CREATE POLICY "Users update own notifications"
  ON notifications FOR UPDATE USING (auth.uid() = user_id);

-- disputes: parties read/insert own
DROP POLICY IF EXISTS "Parties read own disputes" ON disputes;
CREATE POLICY "Parties read own disputes"
  ON disputes FOR SELECT
  USING (auth.uid() IN (initiated_by, against_user_id));

DROP POLICY IF EXISTS "Parties insert disputes" ON disputes;
CREATE POLICY "Parties insert disputes"
  ON disputes FOR INSERT
  WITH CHECK (auth.uid() = initiated_by);

-- time_slots: read only free slots (booking via RPC)
DROP POLICY IF EXISTS "Read free slots" ON time_slots;
CREATE POLICY "Read free slots"
  ON time_slots FOR SELECT
  USING (is_booked = FALSE);

-- payouts: PT read/insert own
DROP POLICY IF EXISTS "PT read own payouts" ON payouts;
CREATE POLICY "PT read own payouts"
  ON payouts FOR SELECT USING (auth.uid() = pt_id);

DROP POLICY IF EXISTS "PT request payouts" ON payouts;
CREATE POLICY "PT request payouts"
  ON payouts FOR INSERT WITH CHECK (auth.uid() = pt_id);

-- =============================================================
-- 4) SECURITY DEFINER RPC: ATOMIC BOOKING
-- =============================================================
CREATE OR REPLACE FUNCTION create_booking(
  p_slot_id UUID,
  p_price_cents INT,
  p_platform_commission_percent DECIMAL(5,2),
  p_platform_commission_fixed_cents INT,
  p_pt_earnings_cents INT
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_slot RECORD;
  v_booking_id UUID;
  v_role user_role;
BEGIN
  SELECT role INTO v_role FROM profiles WHERE id = auth.uid();
  IF NOT FOUND OR v_role <> 'client' THEN
    RAISE EXCEPTION 'Only clients can book sessions';
  END IF;

  SELECT * INTO v_slot
  FROM time_slots
  WHERE id = p_slot_id
    AND is_available = TRUE
    AND is_booked = FALSE
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Slot not available';
  END IF;

  INSERT INTO bookings (
    client_id, pt_id, service_package_id, start_at, end_at, timezone,
    price_cents, currency,
    platform_commission_percent, platform_commission_fixed_cents,
    pt_earnings_cents, status, payment_status
  ) VALUES (
    auth.uid(), v_slot.pt_id, v_slot.service_package_id,
    v_slot.start_at, v_slot.end_at, v_slot.timezone,
    p_price_cents, 'VND',
    p_platform_commission_percent, p_platform_commission_fixed_cents,
    p_pt_earnings_cents, 'pending', 'pending'
  ) RETURNING id INTO v_booking_id;

  UPDATE time_slots
  SET is_booked = TRUE, booking_id = v_booking_id
  WHERE id = p_slot_id;

  RETURN v_booking_id;
END;
$$;

REVOKE ALL ON FUNCTION create_booking FROM PUBLIC;
GRANT EXECUTE ON FUNCTION create_booking TO authenticated;

-- =============================================================
-- 5) AUTOMATION TRIGGERS
-- =============================================================

-- Release escrow + create earnings when booking completes
CREATE OR REPLACE FUNCTION release_payment_on_completion()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status IS DISTINCT FROM 'completed' THEN
    UPDATE payments
    SET status = 'released', released_at = NOW()
    WHERE id = NEW.payment_id AND status = 'held';

    IF NEW.payment_id IS NOT NULL THEN
      INSERT INTO pt_earnings (
        pt_id, booking_id, payment_id,
        gross_amount_cents, platform_commission_percent,
        platform_commission_fixed_cents, platform_commission_cents,
        net_amount_cents, is_released, released_at
      )
      SELECT NEW.pt_id, NEW.id, NEW.payment_id,
             NEW.price_cents, NEW.platform_commission_percent,
             NEW.platform_commission_fixed_cents,
             p.platform_commission_cents,
             NEW.pt_earnings_cents, TRUE, NOW()
      FROM payments p WHERE p.id = NEW.payment_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_release_payment_and_earnings ON bookings;
CREATE TRIGGER trg_release_payment_and_earnings
AFTER UPDATE ON bookings
FOR EACH ROW
WHEN (NEW.status = 'completed')
EXECUTE FUNCTION release_payment_on_completion();

-- Update PT rating on review (already exists in live schema - keep as reference)
-- DROP TRIGGER IF EXISTS trg_update_pt_rating ON reviews;
-- CREATE TRIGGER trg_update_pt_rating ... (see live-schema.md)

-- =============================================================
-- 6) SEED MISSING SETTINGS
-- =============================================================
INSERT INTO platform_settings (key, value, description, is_public)
VALUES ('payout_min_amount_cents',
        '{"min_amount": 50000}',
        'Minimum payout threshold for PTs', true)
ON CONFLICT (key) DO NOTHING;