# Test Accounts

Use these accounts for manual testing against the Supabase project. Passwords are hashed via Supabase Auth (not stored here).

## Client Accounts

| Email | Password | Role | Notes |
|---|---|---|---|
| `client1@test.com` | `Test123456` | `client` | Test client for booking flows |
| `client2@test.com` | `Test123456` | `client` | Second client for multi-user tests |

## PT (Personal Trainer) Accounts

| Email | Password | Role | Notes |
|---|---|---|---|
| `pt1.ontrain@gmail.com` | `Test123456` | `pt` | Existing seeded PT (id: `11111111-1111-1111-1111-000000000001`) |
| `pt2.ontrain@gmail.com` | `Test123456` | `pt` | Existing seeded PT |
| `pt3.ontrain@gmail.com` | `Test123456` | `pt` | Existing seeded PT |
| ... | ... | `pt` | 30+ seeded PT accounts (pt1 through pt36) |

## Admin Account

| Email | Password | Role | Notes |
|---|---|---|---|
| `admin@test.com` | `Test123456` | `admin` | Platform admin for moderation/dispute resolution |

---

## How to Create Test Accounts

### Option 1: Via App (Recommended)
1. Launch app
2. Tap "Sign Up"
3. Enter email/password, select role
4. App calls `Authrepo.signUp()` → inserts into `profiles` table

### Option 2: Via Supabase Dashboard
1. Go to **Authentication → Users**
2. Click **Add User** → enter email/password
3. After user is created, go to **Table Editor → profiles**
4. Insert row with:
   ```json
   {
     "id": "<auth-user-id>",
     "email": "<same-email>",
     "full_name": "Test User",
     "role": "client",  // or "pt", "admin"
     "timezone": "Asia/Ho_Chi_Minh",
     "locale": "vi",
     "is_verified": true
   }
   ```

### Option 3: Via SQL (Bulk)
```sql
-- Run in Supabase SQL Editor
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, role, created_at, updated_at)
VALUES
  (gen_random_uuid(), 'client1@test.com', crypt('Test123456', gen_salt('bf')), now(), 'authenticated', now(), now()),
  (gen_random_uuid(), 'pt1@test.com', crypt('Test123456', gen_salt('bf')), now(), 'authenticated', now(), now());

-- Then insert profiles
INSERT INTO profiles (id, email, full_name, role, timezone, locale, is_verified)
SELECT id, email,
  CASE WHEN email LIKE 'pt%' THEN 'Test PT' ELSE 'Test Client' END,
  CASE WHEN email LIKE 'pt%' THEN 'pt' ELSE 'client' END,
  'Asia/Ho_Chi_Minh', 'vi', true
FROM auth.users
WHERE email IN ('client1@test.com', 'pt1@test.com');
```

---

## Seeded Data Reference

The live database already contains 36 PT accounts:
- Emails: `pt1.ontrain@gmail.com` through `pt36.ontrain@gmail.com`
- All have `role = 'pt'` in `profiles`
- All have corresponding `pt_profiles` rows with `status = 'active'`
- Sample PT (id `11111111-1111-1111-1111-000000000001`):
  - `full_name`: "Nguyễn Văn Hùng"
  - `headline`: "HLV Tang Co & Giảm Mỡ Chuyên Nghiệp"
  - `city`: "Ho Chi Minh City"
  - `avg_rating`: 4.95
  - `total_reviews`: 38
  - `total_sessions_completed`: 240

Tables currently empty (will be populated during testing):
- `service_packages`
- `time_slots`
- `bookings`
- `payments`
- `reviews`
- `specialties`