-- =============================================================
-- OnTrain Dev Seed: Service Packages & Time Slots
-- Run AFTER db-config.sql and after PTs exist in pt_profiles
-- Generates 3 packages per PT + 90 days of slots (Mon-Sat, 7am-9pm)
-- =============================================================

-- Safety: only run if tables are empty
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM service_packages LIMIT 1) THEN
    RAISE NOTICE 'service_packages already seeded, skipping';
    RETURN;
  END IF;
END $$;

-- =============================================================
-- 1) Create Service Packages for each active PT
-- =============================================================
INSERT INTO service_packages (pt_id, name, description, price_cents, duration_minutes, is_active, status)
SELECT
  pt.id,
  pkg.name,
  pkg.description,
  pkg.price_cents,
  pkg.duration_minutes,
  true,
  'active'
FROM pt_profiles pt
CROSS JOIN LATERAL (
  VALUES
    ('Personal Training 60min', 'One-on-one 60 minute session', 300000, 60),
    ('Personal Training 90min', 'One-on-one 90 minute session', 450000, 90),
    ('Group Class 60min', 'Small group training (max 4)', 150000, 60)
) AS pkg(name, description, price_cents, duration_minutes)
WHERE pt.status = 'active';

-- =============================================================
-- 2) Generate Time Slots for 90 days (Mon-Sat, 7am-9pm)
-- =============================================================
DO $$
DECLARE
  v_pt RECORD;
  v_pkg RECORD;
  v_day DATE;
  v_hour INT;
  v_start_at TIMESTAMPTZ;
  v_end_at TIMESTAMPTZ;
  v_slot_count INT := 0;
BEGIN
  -- Loop through each active PT
  FOR v_pt IN
    SELECT id FROM pt_profiles WHERE status = 'active'
  LOOP
    -- Loop through each package for this PT
    FOR v_pkg IN
      SELECT id, duration_minutes FROM service_packages
      WHERE pt_id = v_pt.id AND is_active = true
    LOOP
      -- Generate slots for 90 days starting from tomorrow
      FOR v_day IN
        SELECT generate_series(
          (CURRENT_DATE + INTERVAL '1 day')::DATE,
          (CURRENT_DATE + INTERVAL '90 days')::DATE,
          INTERVAL '1 day'
        )::DATE
      LOOP
        -- Skip Sundays (0 = Sunday in PostgreSQL)
        IF EXTRACT(DOW FROM v_day) = 0 THEN
          CONTINUE;
        END IF;

        -- Generate slots from 7am to 9pm (last start at 8pm for 60min, 7:30pm for 90min)
        FOR v_hour IN 7..20 LOOP
          -- Skip if 90min package would go past 9pm
          IF v_pkg.duration_minutes = 90 AND v_hour > 19 THEN
            CONTINUE;
          END IF;

          v_start_at := v_day + (v_hour || ' hours')::INTERVAL;
          v_end_at := v_start_at + (v_pkg.duration_minutes || ' minutes')::INTERVAL;

          INSERT INTO time_slots (pt_id, service_package_id, start_at, end_at, timezone, is_available, is_booked)
          VALUES (v_pt.id, v_pkg.id, v_start_at, v_end_at, 'UTC', true, false);

          v_slot_count := v_slot_count + 1;
        END LOOP;
      END LOOP;
    END LOOP;
  END LOOP;

  RAISE NOTICE 'Seeded % time slots across all PTs', v_slot_count;
END $$;

-- =============================================================
-- 3) Verify seeding
-- =============================================================
SELECT
  'service_packages' AS table_name,
  COUNT(*) AS count
FROM service_packages
UNION ALL
SELECT
  'time_slots' AS table_name,
  COUNT(*) AS count
FROM time_slots;