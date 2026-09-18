-- =============================================================================
-- ONTRAIN PT MARKETPLACE - COMPLETE POSTGRESQL DDL MIGRATION SCRIPT
-- =============================================================================

BEGIN;

---

-- 0. EXTENSIONS

---

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "btree_gist";
CREATE EXTENSION IF NOT EXISTS "postgis";

---

-- 1. ENUM TYPES

---

CREATE TYPE user_role AS ENUM ('client', 'pt', 'admin');
CREATE TYPE pt_status AS ENUM ('draft', 'pending_review', 'active', 'suspended', 'rejected');
CREATE TYPE service_type AS ENUM ('one_on_one', 'group', 'online');
CREATE TYPE service_status AS ENUM ('active', 'inactive', 'archived');
CREATE TYPE booking_status AS ENUM (
'pending', 'confirmed', 'in_progress', 'completed',
'cancelled_by_client', 'cancelled_by_pt', 'cancelled_by_admin',
'no_show_client', 'no_show_pt', 'disputed', 'refunded'
);
CREATE TYPE payment_status AS ENUM ('pending', 'held', 'released', 'refunded', 'failed', 'disputed');
CREATE TYPE payment_method AS ENUM ('card', 'bank_transfer', 'wallet', 'stripe', 'paypal');
CREATE TYPE payout_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'cancelled');
CREATE TYPE recurrence_frequency AS ENUM ('daily', 'weekly', 'biweekly', 'monthly');
CREATE TYPE week_day AS ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');
CREATE TYPE notification_type AS ENUM (
'booking_request', 'booking_confirmed', 'booking_cancelled', 'booking_reminder',
'session_starting', 'session_completed', 'payment_received', 'payout_initiated',
'payout_completed', 'new_message', 'new_review', 'review_response',
'dispute_opened', 'dispute_resolved', 'account_update', 'promotional', 'system'
);
CREATE TYPE notification_channel AS ENUM ('in_app', 'email', 'push', 'sms');
CREATE TYPE dispute_status AS ENUM ('open', 'under_review', 'resolved_client', 'resolved_pt', 'resolved_split', 'escalated');
CREATE TYPE moderation_status AS ENUM ('pending', 'approved', 'rejected', 'flagged');
CREATE TYPE review_visibility AS ENUM ('public', 'private', 'hidden');

---

-- 2. HELPER FUNCTIONS & TRIGGERS

---

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
NEW.updated_at = NOW();
RETURN NEW;
END;

$$
LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 3. CORE IDENTITY & USER PROFILES
-- -----------------------------------------------------------------------------
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    phone TEXT,
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    role user_role NOT NULL DEFAULT 'client',
    timezone TEXT NOT NULL DEFAULT 'UTC',
    locale TEXT NOT NULL DEFAULT 'en',
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    verification_document_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_active_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_email ON profiles(email);
CREATE INDEX idx_profiles_deleted_at ON profiles(deleted_at) WHERE deleted_at IS NOT NULL;

CREATE TABLE pt_profiles (
    id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    headline TEXT,
    bio TEXT,
    years_experience INT CHECK (years_experience >= 0) DEFAULT 0,
    address TEXT,
    city TEXT,
    state_province TEXT,
    country TEXT DEFAULT 'Vietnam',
    postal_code TEXT,
    location GEOGRAPHY(Point, 4326),
    service_radius_km INT DEFAULT 20,
    business_name TEXT,
    business_registration_number TEXT,
    tax_id TEXT,
    bank_account_name TEXT,
    bank_account_number TEXT,
    bank_name TEXT,
    bank_branch TEXT,
    bank_swift_code TEXT,
    status pt_status NOT NULL DEFAULT 'draft',
    submitted_for_review_at TIMESTAMPTZ,
    reviewed_at TIMESTAMPTZ,
    reviewed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    rejection_reason TEXT,
    avg_rating DECIMAL(3,2) CHECK (avg_rating >= 0 AND avg_rating <= 5) DEFAULT 0,
    total_reviews INT DEFAULT 0,
    total_sessions_completed INT DEFAULT 0,
    auto_accept_bookings BOOLEAN DEFAULT FALSE,
    booking_lead_time_hours INT DEFAULT 2,
    cancellation_policy_hours INT DEFAULT 24,
    slug TEXT UNIQUE,
    meta_title TEXT,
    meta_description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_pt_profiles_status ON pt_profiles(status);
CREATE INDEX idx_pt_profiles_city ON pt_profiles(city);
CREATE INDEX idx_pt_profiles_slug ON pt_profiles(slug) WHERE slug IS NOT NULL;
CREATE INDEX idx_pt_profiles_rating ON pt_profiles(avg_rating DESC) WHERE status = 'active';
CREATE INDEX idx_pt_profiles_location ON pt_profiles USING GIST(location);

-- -----------------------------------------------------------------------------
-- 4. CREDENTIALS & SPECIALTIES
-- -----------------------------------------------------------------------------
CREATE TABLE specialties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_name TEXT,
    category TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE pt_specialties (
    pt_id UUID REFERENCES pt_profiles(id) ON DELETE CASCADE,
    specialty_id UUID REFERENCES specialties(id) ON DELETE CASCADE,
    proficiency_level INT CHECK (proficiency_level BETWEEN 1 AND 5) DEFAULT 1,
    years_experience INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (pt_id, specialty_id)
);

CREATE TABLE pt_certifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    issuing_organization TEXT NOT NULL,
    certificate_number TEXT,
    issue_date DATE NOT NULL,
    expiry_date DATE,
    verification_url TEXT,
    document_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE pt_gallery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE CASCADE,
    media_url TEXT NOT NULL,
    media_type TEXT CHECK (media_type IN ('image','video')),
    caption TEXT,
    display_order INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 5. SERVICES & SCHEDULING
-- -----------------------------------------------------------------------------
CREATE TABLE service_packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    service_type service_type NOT NULL,
    price_cents INT NOT NULL CHECK (price_cents >= 0),
    currency TEXT DEFAULT 'VND',
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    max_participants INT CHECK (max_participants > 0) DEFAULT 1,
    min_participants INT CHECK (min_participants > 0) DEFAULT 1,
    group_discount_percent DECIMAL(5,2) CHECK (group_discount_percent BETWEEN 0 AND 100) DEFAULT 0,
    status service_status NOT NULL DEFAULT 'active',
    advance_booking_days INT DEFAULT 30,
    is_online BOOLEAN DEFAULT FALSE,
    meeting_link_template TEXT,
    location_details TEXT,
    required_equipment TEXT[] DEFAULT '{}',
    difficulty_level INT CHECK (difficulty_level BETWEEN 1 AND 5),
    allow_recurring BOOLEAN DEFAULT TRUE,
    max_recurring_weeks INT DEFAULT 12,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE pt_availability (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE CASCADE,
    service_package_id UUID REFERENCES service_packages(id) ON DELETE SET NULL,
    frequency recurrence_frequency NOT NULL DEFAULT 'weekly',
    week_days week_day[],
    month_day INT CHECK (month_day BETWEEN 1 AND 31),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    valid_from DATE NOT NULL DEFAULT CURRENT_DATE,
    valid_until DATE,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    is_active BOOLEAN DEFAULT TRUE,
    buffer_minutes INT CHECK (buffer_minutes >= 0) DEFAULT 15,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT check_avail_times CHECK (end_time > start_time)
);

CREATE TABLE pt_blocked_dates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE CASCADE,
    start_datetime TIMESTAMPTZ NOT NULL,
    end_datetime TIMESTAMPTZ NOT NULL,
    reason TEXT,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_rule TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT check_blocked_times CHECK (end_datetime > start_datetime)
);

CREATE TABLE time_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE CASCADE,
    service_package_id UUID NOT NULL REFERENCES service_packages(id) ON DELETE CASCADE,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    is_booked BOOLEAN DEFAULT FALSE,
    booking_id UUID,
    source_availability_id UUID REFERENCES pt_availability(id) ON DELETE SET NULL,
    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT check_slot_times CHECK (end_at > start_at),
    CONSTRAINT unique_pt_slot UNIQUE (pt_id, service_package_id, start_at)
);

CREATE INDEX idx_time_slots_available ON time_slots(pt_id, start_at) WHERE is_available = TRUE AND is_booked = FALSE;

-- -----------------------------------------------------------------------------
-- 6. TRANSACTIONS & ESCROW LEDGER
-- -----------------------------------------------------------------------------
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE RESTRICT,
    service_package_id UUID NOT NULL REFERENCES service_packages(id) ON DELETE RESTRICT,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    booking_range TSTZRANGE GENERATED ALWAYS AS (tstzrange(start_at, end_at, '[)')) STORED,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    status booking_status NOT NULL DEFAULT 'pending',
    price_cents INT NOT NULL CHECK (price_cents >= 0),
    currency TEXT DEFAULT 'VND',
    platform_commission_percent DECIMAL(5,2) NOT NULL DEFAULT 15.00,
    platform_commission_fixed_cents INT NOT NULL DEFAULT 0,
    pt_earnings_cents INT CHECK (pt_earnings_cents >= 0),
    payment_id UUID,
    payment_status payment_status NOT NULL DEFAULT 'pending',
    cancelled_at TIMESTAMPTZ,
    cancelled_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    cancellation_reason TEXT,
    cancellation_fee_cents INT DEFAULT 0,
    meeting_link TEXT,
    location_details TEXT,
    client_notes TEXT,
    pt_notes TEXT,
    completed_at TIMESTAMPTZ,
    actual_start_at TIMESTAMPTZ,
    actual_end_at TIMESTAMPTZ,
    dispute_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT no_overlapping_pt_sessions EXCLUDE USING GIST (
        pt_id WITH =,
        booking_range WITH &&
    ) WHERE (status IN ('confirmed', 'in_progress', 'pending'))
);

ALTER TABLE time_slots ADD CONSTRAINT fk_slots_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL;

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    amount_cents INT NOT NULL CHECK (amount_cents > 0),
    currency TEXT DEFAULT 'VND',
    platform_commission_cents INT CHECK (platform_commission_cents >= 0) DEFAULT 0,
    pt_amount_cents INT CHECK (pt_amount_cents >= 0),
    payment_method payment_method NOT NULL,
    external_payment_id TEXT,
    external_payment_data JSONB DEFAULT '{}',
    status payment_status NOT NULL DEFAULT 'pending',
    initiated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    authorized_at TIMESTAMPTZ,
    captured_at TIMESTAMPTZ,
    released_at TIMESTAMPTZ,
    refunded_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    failure_reason TEXT,
    refund_amount_cents INT DEFAULT 0,
    refund_reason TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE bookings ADD CONSTRAINT fk_bookings_payment FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL;

CREATE TABLE payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE RESTRICT,
    amount_cents INT NOT NULL CHECK (amount_cents > 0),
    currency TEXT DEFAULT 'VND',
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    status payout_status NOT NULL DEFAULT 'pending',
    bank_account_name TEXT NOT NULL,
    bank_account_number TEXT NOT NULL,
    bank_name TEXT NOT NULL,
    bank_branch TEXT,
    bank_swift_code TEXT,
    external_transfer_id TEXT,
    external_transfer_data JSONB,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    failure_reason TEXT,
    processed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE pt_earnings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE RESTRICT,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
    gross_amount_cents INT NOT NULL CHECK (gross_amount_cents > 0),
    platform_commission_percent DECIMAL(5,2) NOT NULL,
    platform_commission_fixed_cents INT NOT NULL DEFAULT 0,
    platform_commission_cents INT NOT NULL CHECK (platform_commission_cents >= 0),
    net_amount_cents INT NOT NULL CHECK (net_amount_cents >= 0),
    is_released BOOLEAN DEFAULT FALSE,
    released_at TIMESTAMPTZ,
    payout_id UUID REFERENCES payouts(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 7. SOCIAL & REVIEWS
-- -----------------------------------------------------------------------------
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL UNIQUE REFERENCES bookings(id) ON DELETE RESTRICT,
    client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE RESTRICT,
    service_package_id UUID NOT NULL REFERENCES service_packages(id) ON DELETE RESTRICT,
    overall_rating INT CHECK (overall_rating BETWEEN 1 AND 5) NOT NULL,
    expertise_rating INT CHECK (expertise_rating BETWEEN 1 AND 5),
    communication_rating INT CHECK (communication_rating BETWEEN 1 AND 5),
    punctuality_rating INT CHECK (punctuality_rating BETWEEN 1 AND 5),
    value_rating INT CHECK (value_rating BETWEEN 1 AND 5),
    title TEXT,
    comment TEXT,
    pt_response TEXT,
    pt_responded_at TIMESTAMPTZ,
    visibility review_visibility NOT NULL DEFAULT 'public',
    moderation_status moderation_status NOT NULL DEFAULT 'pending',
    moderated_at TIMESTAMPTZ,
    moderated_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    moderation_notes TEXT,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_client_pt_favorite UNIQUE (client_id, pt_id)
);

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    pt_id UUID NOT NULL REFERENCES pt_profiles(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    subject TEXT,
    status TEXT CHECK (status IN ('active', 'archived', 'blocked')) DEFAULT 'active',
    last_message_at TIMESTAMPTZ,
    last_message_preview TEXT,
    unread_count_client INT DEFAULT 0,
    unread_count_pt INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_conv_booking ON conversations(client_id, pt_id, booking_id) WHERE booking_id IS NOT NULL;
CREATE UNIQUE INDEX idx_conv_no_booking ON conversations(client_id, pt_id) WHERE booking_id IS NULL;

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type TEXT CHECK (message_type IN ('text', 'image', 'file', 'system', 'booking_update')) DEFAULT 'text',
    metadata JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    moderation_status moderation_status NOT NULL DEFAULT 'approved',
    moderated_at TIMESTAMPTZ,
    moderated_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- 8. OPERATIONS & PLATFORM MANAGEMENT
-- -----------------------------------------------------------------------------
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    channel notification_channel NOT NULL DEFAULT 'in_app',
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    failure_reason TEXT,
    scheduled_for TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE disputes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    initiated_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    against_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    reason TEXT NOT NULL,
    description TEXT,
    evidence_urls TEXT[] DEFAULT '{}',
    status dispute_status NOT NULL DEFAULT 'open',
    resolution TEXT,
    refund_amount_cents INT DEFAULT 0,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    resolution_notes TEXT,
    assigned_admin UUID REFERENCES profiles(id) ON DELETE SET NULL,
    priority INT CHECK (priority BETWEEN 1 AND 5) DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE bookings ADD CONSTRAINT fk_bookings_dispute FOREIGN KEY (dispute_id) REFERENCES disputes(id) ON DELETE SET NULL;

CREATE TABLE moderation_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type TEXT CHECK (content_type IN ('pt_profile', 'review', 'message', 'gallery_image', 'certification')),
    content_id UUID NOT NULL,
    reason TEXT,
    reported_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    status moderation_status NOT NULL DEFAULT 'pending',
    priority INT CHECK (priority BETWEEN 1 AND 5) DEFAULT 1,
    assigned_moderator UUID REFERENCES profiles(id) ON DELETE SET NULL,
    moderator_notes TEXT,
    decided_at TIMESTAMPTZ,
    decided_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE platform_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL UNIQUE,
    value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID REFERENCES profiles(id) ON DELETE SET NULL
);

-- Seed Initial Default Settings
INSERT INTO platform_settings (key, value, description, is_public) VALUES
('commission', '{"percent": 15.0, "fixed_cents": 0}', 'Default marketplace commission rate', false),
('cancellation_policy', '{"free_window_hours": 24, "late_fee_percent": 50}', 'Cancellation terms', true);

-- -----------------------------------------------------------------------------
-- 9. ANALYTICS MATERIALIZED VIEWS
-- -----------------------------------------------------------------------------
CREATE MATERIALIZED VIEW pt_monthly_earnings AS
SELECT
    pe.pt_id,
    DATE_TRUNC('month', pe.created_at)::DATE AS month,
    COUNT(DISTINCT pe.booking_id) AS total_sessions,
    SUM(pe.gross_amount_cents) AS gross_revenue_cents,
    SUM(pe.platform_commission_cents) AS platform_fees_cents,
    SUM(pe.net_amount_cents) AS net_earnings_cents,
    AVG(r.overall_rating)::DECIMAL(3,2) AS avg_rating
FROM pt_earnings pe
JOIN bookings b ON pe.booking_id = b.id
LEFT JOIN reviews r ON r.booking_id = b.id
WHERE pe.is_released = TRUE
GROUP BY pe.pt_id, DATE_TRUNC('month', pe.created_at);

CREATE UNIQUE INDEX idx_pt_monthly_earnings ON pt_monthly_earnings(pt_id, month);

-- -----------------------------------------------------------------------------
-- 10. AUTOMATED TRIGGERS
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_pt_rating_on_review()
RETURNS TRIGGER AS
$$

BEGIN
IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.moderation_status = 'approved' THEN
UPDATE pt_profiles
SET
avg_rating = (
SELECT COALESCE(AVG(overall_rating), 0)::DECIMAL(3,2)
FROM reviews
WHERE pt_id = NEW.pt_id AND moderation_status = 'approved' AND visibility = 'public'
),
total_reviews = (
SELECT COUNT(\*)
FROM reviews
WHERE pt_id = NEW.pt_id AND moderation_status = 'approved' AND visibility = 'public'
)
WHERE id = NEW.pt_id;
END IF;
RETURN NEW;
END;

$$
LANGUAGE plpgsql;

CREATE TRIGGER trg_recalculate_pt_rating
AFTER INSERT OR UPDATE ON reviews
FOR EACH ROW EXECUTE FUNCTION update_pt_rating_on_review();

-- Apply updated_at Triggers
CREATE TRIGGER trg_profiles_updated BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_pt_profiles_updated BEFORE UPDATE ON pt_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_service_packages_updated BEFORE UPDATE ON service_packages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_bookings_updated BEFORE UPDATE ON bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_payments_updated BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- -----------------------------------------------------------------------------
-- 11. ROW LEVEL SECURITY (RLS) POLICIES
-- -----------------------------------------------------------------------------
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE pt_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE pt_earnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE platform_settings ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Public profiles read" ON profiles FOR SELECT USING (deleted_at IS NULL);
CREATE POLICY "Users update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- PT Profiles Policies
CREATE POLICY "Active PT profiles public read" ON pt_profiles FOR SELECT USING (status = 'active');
CREATE POLICY "PT manage own profile" ON pt_profiles FOR ALL USING (auth.uid() = id);

-- Service Packages Policies
CREATE POLICY "Service packages public read" ON service_packages FOR SELECT USING (status = 'active');
CREATE POLICY "PT manage own packages" ON service_packages FOR ALL USING (auth.uid() = pt_id);

-- Bookings Policies
CREATE POLICY "Clients read own bookings" ON bookings FOR SELECT USING (auth.uid() = client_id);
CREATE POLICY "PTs read own bookings" ON bookings FOR SELECT USING (auth.uid() = pt_id);

-- Financial Ledger Security (PTs only read their earnings)
CREATE POLICY "PT read own earnings ledger" ON pt_earnings FOR SELECT USING (auth.uid() = pt_id);

-- Platform Settings Policies
CREATE POLICY "Public settings read" ON platform_settings FOR SELECT USING (is_public = TRUE);

COMMIT;
$$
