-- Atomic PT payout request.
--
-- The client only has SELECT on pt_earnings, so the payout row and the
-- earning links must be created together by a SECURITY DEFINER function.
CREATE OR REPLACE FUNCTION public.request_payout()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_pt_id UUID := auth.uid();
  v_total INT;
  v_min INT;
  v_payout_id UUID;
  v_period_start DATE;
  v_earning_ids UUID[];
  v_acct_name TEXT;
  v_acct_no TEXT;
  v_bank TEXT;
  v_branch TEXT;
BEGIN
  IF v_pt_id IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;

  -- Serialize payout requests per PT so two taps cannot double-link earnings.
  PERFORM pg_advisory_xact_lock(hashtext(v_pt_id::text));

  SELECT bank_account_name, bank_account_number, bank_name, bank_branch
    INTO v_acct_name, v_acct_no, v_bank, v_branch
    FROM pt_profiles
   WHERE id = v_pt_id;

  IF NOT FOUND
     OR COALESCE(v_acct_name, '') = ''
     OR COALESCE(v_acct_no, '') = ''
     OR COALESCE(v_bank, '') = '' THEN
    RAISE EXCEPTION 'bank details not configured';
  END IF;

  -- Capture the exact earning rows in the same statement that totals them.
  -- A booking can be released concurrently; without capturing ids, the later
  -- UPDATE could link an earning whose amount was not included in v_total.
  SELECT COALESCE(SUM(net_amount_cents), 0),
         MIN(created_at)::DATE,
         COALESCE(array_agg(id), '{}'::UUID[])
    INTO v_total, v_period_start, v_earning_ids
    FROM (
      SELECT id, net_amount_cents, created_at
        FROM pt_earnings
       WHERE pt_id = v_pt_id
         AND is_released = TRUE
         AND payout_id IS NULL
       FOR UPDATE
    ) eligible;

  IF v_total = 0 THEN
    RAISE EXCEPTION 'no available earnings';
  END IF;

  SELECT COALESCE((value ->> 'min_amount')::INT, 50000)
    INTO v_min
    FROM platform_settings
   WHERE key = 'payout_min_amount_cents';

  IF v_total < COALESCE(v_min, 50000) THEN
    RAISE EXCEPTION 'below minimum payout';
  END IF;

  INSERT INTO payouts (
    pt_id, amount_cents, currency, period_start, period_end, status,
    bank_account_name, bank_account_number, bank_name, bank_branch
  ) VALUES (
    v_pt_id, v_total, 'VND', v_period_start, CURRENT_DATE, 'pending',
    v_acct_name, v_acct_no, v_bank, v_branch
  ) RETURNING id INTO v_payout_id;

  UPDATE pt_earnings
     SET payout_id = v_payout_id
   WHERE id = ANY(v_earning_ids);

  RETURN v_payout_id;
END;
$$;

REVOKE ALL ON FUNCTION public.request_payout() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.request_payout() TO authenticated;
