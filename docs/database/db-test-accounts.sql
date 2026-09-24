-- =============================================================
-- OnTrain Test Accounts & Data Setup
-- Run in Supabase SQL Editor to create test PT + Client + seed data
-- =============================================================

-- =============================================================
-- 1) Create Test Users in auth.users
-- =============================================================
-- PT User
INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    confirmation_token,
    email_change_token_new,
    recovery_token
) VALUES (
    '11111111-1111-1111-1111-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'pt1@test.com',
    crypt('Test123456', gen_salt('bf')),
    now(),
    now(),
    now(),
    '',
    '',
    ''
) ON CONFLICT (id) DO NOTHING;

-- Client User
INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    confirmation_token,
    email_change_token_new,
    recovery_token
) VALUES (
    '22222222-2222-2222-2222-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'client1@test.com',
    crypt('Test123456', gen_salt('bf')),
    now(),
    now(),
    now(),
    '',
    '',
    ''
) ON CONFLICT (id) DO NOTHING;

-- =============================================================
-- 2) Create Profiles
-- =============================================================
-- PT Profile
INSERT INTO profiles (
    id,
    email,
    full_name,
    role,
    timezone,
    locale,
    is_verified,
    created_at,
    updated_at
) VALUES (
    '11111111-1111-1111-1111-000000000001',
    'pt1@test.com',
    'Test PT Trainer',
    'pt',
    'Asia/Ho_Chi_Minh',
    'vi',
    true,
    now(),
    now()
) ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role,
    is_verified = EXCLUDED.is_verified;

-- Client Profile
INSERT INTO profiles (
    id,
    email,
    full_name,
    role,
    timezone,
    locale,
    is_verified,
    created_at,
    updated_at
) VALUES (
    '22222222-2222-2222-2222-000000000002',
    'client1@test.com',
    'Test Client',
    'client',
    'Asia/Ho_Chi_Minh',
    'vi',
    true,
    now(),
    now()
) ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role,
    is_verified = EXCLUDED.is_verified;

-- =============================================================
-- 3) Create PT Profile (pt_profiles) - ACTIVE with bank details
-- =============================================================
INSERT INTO pt_profiles (
    id,
    headline,
    bio,
    years_experience,
    address,
    city,
    state_province,
    country,
    postal_code,
    location,
    service_radius_km,
    business_name,
    business_registration_number,
    tax_id,
    bank_account_name,
    bank_account_number,
    bank_name,
    bank_branch,
    bank_swift_code,
    status,
    avg_rating,
    total_reviews,
    total_sessions_completed,
    auto_accept_bookings,
    booking_lead_time_hours,
    cancellation_policy_hours,
    slug,
    created_at,
    updated_at
) VALUES (
    '11111111-1111-1111-1111-000000000001',
    'Certified Personal Trainer - Strength & Conditioning',
    '10+ years experience helping clients achieve fitness goals. Specialized in strength training, weight loss, and mobility.',
    10,
    '123 Fitness Street',
    'Ho Chi Minh City',
    'HCMC',
    'Vietnam',
    '700000',
    ST_SetSRID(ST_MakePoint(106.6297, 10.8231), 4326),
    20,
    'Test Fitness Studio',
    'BUS123456',
    'TAX789012',
    'Test PT Trainer',
    '1234567890',
    'Vietcombank',
    'District 1 Branch',
    'BFTVVNVX',
    'active',
    4.8,
    25,
    150,
    true,
    2,
    24,
    'test-pt-trainer',
    now(),
    now()
) ON CONFLICT (id) DO UPDATE SET
    headline = EXCLUDED.headline,
    bio = EXCLUDED.bio,
    status = EXCLUDED.status,
    bank_account_name = EXCLUDED.bank_account_name,
    bank_account_number = EXCLUDED.bank_account_number,
    bank_name = EXCLUDED.bank_name,
    bank_branch = EXCLUDED.bank_branch;

-- =============================================================
-- 4) Create Service Packages for PT
-- =============================================================
INSERT INTO service_packages (
    id,
    pt_id,
    name,
    description,
    price_cents,
    duration_minutes,
    is_active,
    status,
    created_at,
    updated_at
) VALUES
    (gen_random_uuid(), '11111111-1111-1111-1111-000000000001', 'Personal Training 60min', 'One-on-one 60 minute session', 300000, 60, true, 'active', now(), now()),
    (gen_random_uuid(), '11111111-1111-1111-1111-000000000001', 'Personal Training 90min', 'One-on-one 90 minute session', 450000, 90, true, 'active', now(), now()),
    (gen_random_uuid(), '11111111-1111-1111-1111-000000000001', 'Group Class 60min', 'Small group training (max 4)', 150000, 60, true, 'active', now(), now())
ON CONFLICT DO NOTHING;

-- =============================================================
-- 5) Create Time Slots (next 30 days, Mon-Sat, 7am-9pm)
-- =============================================================
DO $$
DECLARE
    v_pt_id UUID := '11111111-1111-1111-1111-000000000001';
    v_pkg RECORD;
    v_day DATE;
    v_hour INT;
    v_start_at TIMESTAMPTZ;
    v_end_at TIMESTAMPTZ;
BEGIN
    FOR v_pkg IN
        SELECT id, duration_minutes FROM service_packages
        WHERE pt_id = v_pt_id AND is_active = true
    LOOP
        FOR v_day IN
            SELECT generate_series(
                (CURRENT_DATE + INTERVAL '1 day')::DATE,
                (CURRENT_DATE + INTERVAL '30 days')::DATE,
                INTERVAL '1 day'
            )::DATE
        LOOP
            IF EXTRACT(DOW FROM v_day) = 0 THEN CONTINUE; END IF; -- Skip Sunday

            FOR v_hour IN 7..20 LOOP
                IF v_pkg.duration_minutes = 90 AND v_hour > 19 THEN CONTINUE; END IF;

                v_start_at := v_day + (v_hour || ' hours')::INTERVAL;
                v_end_at := v_start_at + (v_pkg.duration_minutes || ' minutes')::INTERVAL;

                INSERT INTO time_slots (pt_id, service_package_id, start_at, end_at, timezone, is_available, is_booked)
                VALUES (v_pt_id, v_pkg.id, v_start_at, v_end_at, 'UTC', true, false)
                ON CONFLICT DO NOTHING;
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

-- =============================================================
-- 6) Verify Setup
-- =============================================================
SELECT 'auth.users' AS table_name, COUNT(*) FROM auth.users WHERE email IN ('pt1@test.com', 'client1@test.com')
UNION ALL
SELECT 'profiles', COUNT(*) FROM profiles WHERE id IN ('11111111-1111-1111-1111-000000000001', '22222222-2222-2222-2222-000000000002')
UNION ALL
SELECT 'pt_profiles', COUNT(*) FROM pt_profiles WHERE id = '11111111-1111-1111-1111-000000000001'
UNION ALL
SELECT 'service_packages', COUNT(*) FROM service_packages WHERE pt_id = '11111111-1111-1111-1111-000000000001'
UNION ALL
SELECT 'time_slots (available)', COUNT(*) FROM time_slots WHERE pt_id = '11111111-1111-1111-1111-000000000001' AND is_available = true AND is_booked = false;