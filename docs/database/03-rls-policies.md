# RLS Policies Reference

> **OnTrain PT Marketplace** — Row Level Security policies for all tables.
> Run `supabase db pull` or check Supabase Dashboard → Authentication → Policies to verify.

---

## Quick Reference Matrix

| Table | Client | PT | Admin |
|-------|--------|-----|-------|
| `profiles` | R/U own | R own + R clients with bookings | CRUD all |
| `pt_profiles` | R active | CRUD own | CRUD all |
| `specialties` | R active | — | CRUD |
| `pt_certifications` | R verified (active PT) | CRUD own | CRUD all |
| `pt_specialties` | R (active PT) | CRUD own | CRUD all |
| `pt_gallery` | R (active PT) | CRUD own | CRUD all |
| `service_packages` | R (active PT, active pkg) | CRUD own | CRUD all |
| `pt_availability` | R (active PT, active) | CRUD own | CRUD all |
| `pt_blocked_dates` | — | CRUD own | CRUD all |
| `time_slots` | R available | R own | CRUD all |
| `bookings` | CRUD own (status limits) | R own + U status | CRUD all |
| `payments` | R own | R for own bookings | CRUD all |
| `payouts` | — | CRUD own (pending insert) | CRUD all |
| `pt_earnings` | — | R own | R all |
| `reviews` | C (completed), U own | U response | CRUD (moderate) |
| `favorites` | CRUD own | — | R all |
| `conversations` | R/U own | R/U own | R all |
| `messages` | R/C in active conv | R/C in active conv | R all |
| `notifications` | R/U own | R/U own | R all |
| `disputes` | R/C own | R/C own | CRUD all |
| `moderation_queue` | R own reports | — | CRUD all |
| `platform_settings` | R public | — | CRUD all |

**Legend:** C=Create, R=Read, U=Update, D=Delete

---

## Detailed Policies by Table

### `profiles`

```sql
-- Users can view own profile
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Users can update own profile
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- PTs can view client profiles for their bookings
CREATE POLICY "PTs can view client profiles for bookings" ON profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM bookings b
            WHERE b.pt_id = auth.uid() AND b.client_id = profiles.id
        )
    );

-- Clients can view active PT profiles
CREATE POLICY "Clients can view active PT profiles" ON profiles
    FOR SELECT USING (
        role = 'pt' AND
        EXISTS (
            SELECT 1 FROM pt_profiles pp
            WHERE pp.id = profiles.id AND pp.status = 'active'
        )
    );

-- Admins can view all profiles
CREATE POLICY "Admins can view all profiles" ON profiles
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );
```

**Dart Query Implications:**
```dart
// Client: supabase.from('profiles').select().eq('id', userId).single()
// PT viewing client: supabase.from('profiles').select().eq('id', clientId).single()
//   → Works only if booking exists between them
// Admin: no filter needed
```

---

### `pt_profiles`

```sql
-- PTs can manage own profile
CREATE POLICY "PTs can manage own profile" ON pt_profiles
    FOR ALL USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Public can view active PT profiles
CREATE POLICY "Public can view active PT profiles" ON pt_profiles
    FOR SELECT USING (status = 'active');

-- Admins can view all PT profiles
CREATE POLICY "Admins can view all PT profiles" ON pt_profiles
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Admins can update PT status
CREATE POLICY "Admins can update PT status" ON pt_profiles
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    ) WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );
```

---

### `service_packages`

```sql
-- PTs can manage own service packages
CREATE POLICY "PTs can manage own service packages" ON service_packages
    FOR ALL USING (pt_id = auth.uid()) WITH CHECK (pt_id = auth.uid());

-- Public can view active packages for active PTs
CREATE POLICY "Public can view active service packages" ON service_packages
    FOR SELECT USING (
        status = 'active' AND
        EXISTS (SELECT 1 FROM pt_profiles WHERE id = pt_id AND status = 'active')
    );

-- Clients can view packages they have bookings for
CREATE POLICY "Clients can view booked packages" ON service_packages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM bookings b
            WHERE b.service_package_id = service_packages.id
            AND b.client_id = auth.uid()
        )
    );
```

---

### `pt_availability`

```sql
-- PTs can manage own availability
CREATE POLICY "PTs can manage own availability" ON pt_availability
    FOR ALL USING (pt_id = auth.uid()) WITH CHECK (pt_id = auth.uid());

-- Public can view active availability for active PTs
CREATE POLICY "Public can view active PT availability" ON pt_availability
    FOR SELECT USING (
        is_active = TRUE AND
        EXISTS (SELECT 1 FROM pt_profiles WHERE id = pt_id AND status = 'active')
    );
```

---

### `pt_blocked_dates`

```sql
-- PTs can manage own blocked dates
CREATE POLICY "PTs can manage own blocked dates" ON pt_blocked_dates
    FOR ALL USING (pt_id = auth.uid()) WITH CHECK (pt_id = auth.uid());
```

---

### `time_slots`

```sql
-- PTs can view own time slots
CREATE POLICY "PTs can view own time slots" ON time_slots
    FOR SELECT USING (pt_id = auth.uid());

-- Clients can view available slots for active PTs
CREATE POLICY "Clients can view available time slots" ON time_slots
    FOR SELECT USING (
        is_available = TRUE AND is_booked = FALSE AND
        EXISTS (SELECT 1 FROM pt_profiles WHERE id = pt_id AND status = 'active')
    );

-- System/Admin can manage time slots
CREATE POLICY "System can manage time slots" ON time_slots
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );
```

**Dart Query - Get Available Slots:**
```dart
// Client side
final slots = await supabase
  .from('time_slots')
  .select('*, service_packages(*)')
  .eq('pt_id', ptId)
  .eq('is_available', true)
  .eq('is_booked', false)
  .gte('start_at', fromDate.toIso8601String())
  .lte('start_at', toDate.toIso8601String())
  .order('start_at');

// PT side (sees all including booked)
final mySlots = await supabase
  .from('time_slots')
  .select('*, bookings(client_id, status)')
  .eq('pt_id', myPtId)
  .gte('start_at', fromDate.toIso8601String())
  .lte('start_at', toDate.toIso8601String());
```

---

### `bookings`

```sql
-- Clients can view own bookings
CREATE POLICY "Clients can view own bookings" ON bookings
    FOR SELECT USING (client_id = auth.uid());

-- PTs can view own bookings
CREATE POLICY "PTs can view own bookings" ON bookings
    FOR SELECT USING (pt_id = auth.uid());

-- Clients can create bookings (pending only)
CREATE POLICY "Clients can create bookings" ON bookings
    FOR INSERT WITH CHECK (
        client_id = auth.uid() AND
        status = 'pending'
    );

-- PTs can update booking status
CREATE POLICY "PTs can update booking status" ON bookings
    FOR UPDATE USING (pt_id = auth.uid()) WITH CHECK (pt_id = auth.uid());

-- Clients can cancel own bookings (pending/confirmed only)
CREATE POLICY "Clients can cancel own bookings" ON bookings
    FOR UPDATE USING (
        client_id = auth.uid() AND
        status IN ('pending', 'confirmed')
    ) WITH CHECK (
        client_id = auth.uid() AND
        status = 'cancelled_by_client'
    );

-- Admins can manage all bookings
CREATE POLICY "Admins can manage all bookings" ON bookings
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );
```

**Status Transition Rules (enforced by CHECK + RLS):**
```
Client can: INSERT(pending) → UPDATE(cancelled_by_client) from pending/confirmed
PT can:     UPDATE(confirmed/in_progress/completed/cancelled_by_pt/no_show_client)
Admin:      Any transition
```

---

### `payments`

```sql
-- Clients can view own payments
CREATE POLICY "Clients can view own payments" ON payments
    FOR SELECT USING (client_id = auth.uid());

-- PTs can view payments for their bookings
CREATE POLICY "PTs can view payments for their bookings" ON payments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM bookings b
            WHERE b.id = payments.booking_id AND b.pt_id = auth.uid()
        )
    );

-- System can manage payments
CREATE POLICY "System can manage payments" ON payments
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );
```

---

### `payouts`

```sql
-- PTs can view own payouts
CREATE POLICY "PTs can view own payouts" ON payouts
    FOR SELECT USING (pt_id = auth.uid());

-- PTs can request payouts
CREATE POLICY "PTs can request payouts" ON payouts
    FOR INSERT WITH CHECK (pt_id = auth.uid() AND status = 'pending');

-- Admins can manage payouts
CREATE POLICY "Admins can manage payouts" ON payouts
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );
```

---

### `pt_earnings`

```sql
-- PTs can view own earnings
CREATE POLICY "PTs can view own earnings" ON pt_earnings
    FOR SELECT USING (pt_id = auth.uid());
```

---

### `reviews`

```sql
-- Clients can create reviews for completed bookings
CREATE POLICY "Clients can create reviews" ON reviews
    FOR INSERT WITH CHECK (
        client_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM bookings b
            WHERE b.id = reviews.booking_id
            AND b.client_id = auth.uid()
            AND b.status = 'completed'
        )
    );

-- Clients can update own reviews
CREATE POLICY "Clients can update own reviews" ON reviews
    FOR UPDATE USING (client_id = auth.uid()) WITH CHECK (client_id = auth.uid());

-- PTs can respond to reviews
CREATE POLICY "PTs can respond to reviews" ON reviews
    FOR UPDATE USING (
        pt_id = auth.uid() AND
        pt_response IS NOT NULL
    ) WITH CHECK (pt_id = auth.uid());

-- Public can view approved reviews
CREATE POLICY "Public can view approved reviews" ON reviews
    FOR SELECT USING (visibility = 'public' AND moderation_status = 'approved');

-- Users can view reviews for their bookings
CREATE POLICY "Users can view own booking reviews" ON reviews
    FOR SELECT USING (client_id = auth.uid() OR pt_id = auth.uid());

-- Admins can moderate reviews
CREATE POLICY "Admins can moderate reviews" ON reviews
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );
```

---

### `favorites`

```sql
-- Clients can manage own favorites
CREATE POLICY "Clients can manage own favorites" ON favorites
    FOR ALL USING (client_id = auth.uid()) WITH CHECK (client_id = auth.uid());
```

---

### `conversations`

```sql
-- Participants can view conversations
CREATE POLICY "Participants can view conversations" ON conversations
    FOR SELECT USING (client_id = auth.uid() OR pt_id = auth.uid());

-- Clients can create conversations
CREATE POLICY "Clients can create conversations" ON conversations
    FOR INSERT WITH CHECK (client_id = auth.uid());

-- Participants can update conversations
CREATE POLICY "Participants can update conversations" ON conversations
    FOR UPDATE USING (client_id = auth.uid() OR pt_id = auth.uid());
```

---

### `messages`

```sql
-- Participants can view messages
CREATE POLICY "Participants can view messages" ON messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM conversations c
            WHERE c.id = messages.conversation_id
            AND (c.client_id = auth.uid() OR c.pt_id = auth.uid())
        )
    );

-- Participants can send messages in active conversations
CREATE POLICY "Participants can send messages" ON messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM conversations c
            WHERE c.id = messages.conversation_id
            AND (c.client_id = auth.uid() OR c.pt_id = auth.uid())
            AND c.status = 'active'
        )
    );
```

---

### `notifications`

```sql
-- Users can view own notifications
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (user_id = auth.uid());

-- Users can update own notifications (mark read)
CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
```

---

### `disputes`

```sql
-- Parties can view their disputes
CREATE POLICY "Parties can view their disputes" ON disputes
    FOR SELECT USING (initiated_by = auth.uid() OR against_user_id = auth.uid());

-- Parties can create disputes for their bookings
CREATE POLICY "Parties can create disputes" ON disputes
    FOR INSERT WITH CHECK (
        initiated_by = auth.uid() AND
        EXISTS (
            SELECT 1 FROM bookings b
            WHERE b.id = disputes.booking_id
            AND (b.client_id = auth.uid() OR b.pt_id = auth.uid())
        )
    );

-- Admins can manage disputes
CREATE POLICY "Admins can manage disputes" ON disputes
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );
```

---

### `moderation_queue`

```sql
-- Admins can manage moderation queue
CREATE POLICY "Admins can manage moderation queue" ON moderation_queue
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Users can view their reported content
CREATE POLICY "Users can view their reported content" ON moderation_queue
    FOR SELECT USING (reported_by = auth.uid());
```

---

### `platform_settings`

```sql
-- Public can read public settings
CREATE POLICY "Public can read public settings" ON platform_settings
    FOR SELECT USING (is_public = TRUE);

-- Admins can manage all settings
CREATE POLICY "Admins can manage all settings" ON platform_settings
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );
```

---

### `specialties`

```sql
-- Public can view active specialties
CREATE POLICY "Public can view active specialties" ON specialties
    FOR SELECT USING (is_active = TRUE);

-- Admins can manage specialties
CREATE POLICY "Admins can manage specialties" ON specialties
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );
```

---

## Testing RLS Policies

### Supabase Dashboard Method
1. Go to **Authentication → Policies**
2. Select table
3. Click **"Test Policy"** button
4. Enter `auth.uid()` value and test SELECT/INSERT/UPDATE/DELETE

### SQL Test Method
```sql
-- Impersonate a user
SET ROLE authenticated;
SET request.jwt.claims = '{"sub": "user-uuid-here", "role": "authenticated"}';

-- Test query
SELECT * FROM bookings WHERE client_id = auth.uid();
-- Should return only that user's bookings

RESET ROLE;
```

### Dart Integration Test
```dart
testWidgets('Client cannot see other client bookings', (tester) async {
  // Login as client A
  await supabase.auth.signInWithPassword(email: 'clientA@test.com', password: 'pass');
  
  // Try to fetch client B's bookings
  final result = await supabase
    .from('bookings')
    .select()
    .eq('client_id', 'client-B-uuid');
  
  expect(result, isEmpty); // RLS blocks it
});
```

---

## Common RLS Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| `new row violates row-level security policy` | INSERT missing required FK (e.g., `client_id = auth.uid()`) | Ensure all INSERTs include owning user FK |
| `permission denied for table` | SELECT on table with no matching policy | Verify user role matches at least one policy |
| PT can't see client name in booking join | `profiles` RLS blocks client profile | Use `bookings` SELECT with join - PT policy allows it |
| Admin queries return empty | Admin role not in `profiles.role` | Ensure admin user has `role = 'admin'` in profiles |
| `time_slots` not visible to client | `is_available=false` or `is_booked=true` or PT not active | Check all three conditions + PT status |

---

*Generated for OnTrain v1.0 — Keep in sync with Supabase Dashboard*