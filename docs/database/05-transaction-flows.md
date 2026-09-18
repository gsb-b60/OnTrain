# Transaction Flows & Lifecycle

> **OnTrain PT Marketplace** — Complete lifecycle documentation for Booking → Payment → Payout flows.
> All state transitions, triggers, and edge cases.

---

## Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   BOOKING   │────▶│  PAYMENT    │────▶│   EARNINGS  │────▶│   PAYOUT    │
│  (client)   │     │  (escrow)   │     │  (ledger)   │     │  (bank)     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │                   │
      ▼                   ▼                   ▼                   ▼
 pending            held/released         created on           requested by
 confirmed          refunded              completion           PT, processed
 completed                                               by admin
 cancelled
 disputed
```

---

## 1. Booking Lifecycle

### 1.1 State Diagram

```
                    ┌─────────────────────┐
                    │      PENDING        │◀── Client creates
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              ▼                ▼                ▼
    ┌─────────────────┐ ┌─────────────┐ ┌─────────────────┐
    │    CONFIRMED    │ │ CANCELLED_  │ │  CANCELLED_     │
    │  (PT accepts)   │ │  BY_CLIENT  │ │   BY_PT         │
    └────────┬────────┘ └──────┬──────┘ └────────┬────────┘
             │                 │                  │
             ▼                 │                  ▼
    ┌─────────────────┐        │         ┌─────────────────┐
    │  IN_PROGRESS    │        │         │  CANCELLED_     │
    │ (session start) │        │         │   BY_ADMIN      │
    └────────┬────────┘        │         └────────┬────────┘
             │                 │                  │
             ▼                 │                  │
    ┌─────────────────┐        │                  │
    │   COMPLETED     │        │                  │
    │ (session end)   │        │                  │
    └────────┬────────┘        │                  │
             │                 │                  │
      ┌──────┴──────┐          │                  │
      ▼             ▼          │                  │
┌───────────┐  ┌──────────┐    │                  │
│  RELEASE  │  │  DISPUTE │    │                  │
│  PAYMENT  │  │  OPENED  │    │                  │
└─────┬─────┘  └────┬─────┘    │                  │
      │             │          │                  │
      ▼             ▼          ▼                  ▼
┌───────────┐  ┌──────────┐ ┌─────────┐    ┌─────────────┐
│  PT PAID  │  │ RESOLVED │ │ REFUNDED│    │  NO_SHOW_*  │
│  (earnings)│  │          │ │(payment)│    │  (auto)     │
└───────────┘  └──────────┘ └─────────┘    └─────────────┘
```

### 1.2 Status Definitions

| Status | Who Sets | When | Next Valid States |
|--------|----------|------|-------------------|
| `pending` | Client (INSERT) | Booking created | `confirmed`, `cancelled_by_client` |
| `confirmed` | PT (UPDATE) | PT accepts | `in_progress`, `cancelled_by_pt`, `cancelled_by_client` |
| `in_progress` | PT/System (UPDATE) | Session start time | `completed`, `no_show_client`, `no_show_pt`, `cancelled_by_admin` |
| `completed` | PT/System (UPDATE) | Session end time | `disputed` (rare, post-completion) |
| `cancelled_by_client` | Client (UPDATE) | Client cancels | — (terminal) |
| `cancelled_by_pt` | PT (UPDATE) | PT cancels | — (terminal) |
| `cancelled_by_admin` | Admin (UPDATE) | Admin intervention | — (terminal) |
| `no_show_client` | System/PT (UPDATE) | Client doesn't show | `disputed`, `refunded` |
| `no_show_pt` | System/Client (UPDATE) | PT doesn't show | `disputed`, `refunded` |
| `disputed` | Either party (INSERT dispute) | Dispute filed | `resolved_client`, `resolved_pt`, `resolved_split`, `refunded` |
| `refunded` | Admin/System (UPDATE) | Refund processed | — (terminal) |

### 1.3 Booking Creation (Client Side)

```dart
// 1. Validate slot availability
final slot = await supabase
  .from('time_slots')
  .select('*, service_packages(*)')
  .eq('id', slotId)
  .eq('is_available', true)
  .eq('is_booked', false)
  .single();

// 2. Get commission settings
final commission = await supabase
  .from('platform_settings')
  .select('value')
  .eq('key', 'commission')
  .single();
final commissionPct = (commission['value'] as Map)['percent'] as double;
final commissionFixed = (commission['value'] as Map)['fixed_cents'] as int;

// 3. Calculate amounts
final priceCents = slot['service_packages']['price_cents'] as int;
final platformCommissionCents = (priceCents * commissionPct / 100).round() + commissionFixed;
final ptEarningsCents = priceCents - platformCommissionCents;

// 4. Create booking (atomic via RPC recommended)
final booking = await supabase.rpc('create_booking', params: {
  'p_client_id': userId,
  'p_slot_id': slotId,
  'p_price_cents': priceCents,
  'p_platform_commission_percent': commissionPct,
  'p_platform_commission_fixed_cents': commissionFixed,
  'p_pt_earnings_cents': ptEarningsCents,
});

// 5. Create payment record (held via Stripe)
await supabase.from('payments').insert({
  'booking_id': booking['id'],
  'client_id': userId,
  'amount_cents': priceCents,
  'platform_commission_cents': platformCommissionCents,
  'pt_amount_cents': ptEarningsCents,
  'payment_method': 'stripe',
  'status': 'held',
  'external_payment_id': stripePaymentIntentId,
});
```

### 1.4 RPC: `create_booking` (Atomic)

```sql
CREATE OR REPLACE FUNCTION create_booking(
  p_client_id UUID,
  p_slot_id UUID,
  p_price_cents INT,
  p_platform_commission_percent DECIMAL(5,2),
  p_platform_commission_fixed_cents INT,
  p_pt_earnings_cents INT
) RETURNS UUID AS $$
DECLARE
  v_booking_id UUID;
  v_slot RECORD;
BEGIN
  -- Lock slot for update
  SELECT * INTO v_slot FROM time_slots 
  WHERE id = p_slot_id 
  AND is_available = TRUE 
  AND is_booked = FALSE
  FOR UPDATE;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Slot not available';
  END IF;
  
  -- Create booking
  INSERT INTO bookings (
    client_id, pt_id, service_package_id,
    start_at, end_at, timezone,
    price_cents, currency,
    platform_commission_percent, platform_commission_fixed_cents,
    pt_earnings_cents, status, payment_status
  ) VALUES (
    p_client_id, v_slot.pt_id, v_slot.service_package_id,
    v_slot.start_at, v_slot.end_at, 'UTC',
    p_price_cents, 'VND',
    p_platform_commission_percent, p_platform_commission_fixed_cents,
    p_pt_earnings_cents, 'pending', 'pending'
  ) RETURNING id INTO v_booking_id;
  
  -- Mark slot as booked
  UPDATE time_slots 
  SET is_booked = TRUE, booking_id = v_booking_id
  WHERE id = p_slot_id;
  
  RETURN v_booking_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 2. Payment Flow (Escrow/Hold/Release)

### 2.1 Payment States

| Status | Meaning | Trigger |
|--------|---------|---------|
| `pending` | Payment initiated, not authorized | Client starts checkout |
| `held` | Funds authorized & captured, held in escrow | Stripe `payment_intent.succeeded` |
| `released` | Funds released to PT earnings | Booking `completed` + trigger |
| `refunded` | Funds returned to client | Cancellation/refund |
| `failed` | Payment failed | Stripe `payment_intent.payment_failed` |
| `disputed` | Chargeback/dispute opened | Stripe dispute or manual |

### 2.2 Stripe Webhook Handling (Edge Function)

```typescript
// supabase/functions/stripe-webhook/index.ts
export default async (req: Request) => {
  const sig = req.headers.get('stripe-signature');
  const event = stripe.webhooks.constructEvent(
    await req.text(), sig, STRIPE_WEBHOOK_SECRET
  );

  switch (event.type) {
    case 'payment_intent.succeeded': {
      const pi = event.data.object;
      await supabase.from('payments').update({
        status: 'held',
        authorized_at: new Date().toISOString(),
        captured_at: new Date().toISOString(),
        external_payment_data: pi,
      }).eq('external_payment_id', pi.id);
      break;
    }
    case 'payment_intent.payment_failed': {
      const pi = event.data.object;
      await supabase.from('payments').update({
        status: 'failed',
        failed_at: new Date().toISOString(),
        failure_reason: pi.last_payment_error?.message,
      }).eq('external_payment_id', pi.id);
      break;
    }
    case 'charge.refunded': {
      const charge = event.data.object;
      await supabase.from('payments').update({
        status: 'refunded',
        refunded_at: new Date().toISOString(),
        refund_amount_cents: charge.amount_refunded,
      }).eq('external_payment_id', charge.payment_intent);
      break;
    }
    case 'charge.dispute.created': {
      const dispute = event.data.object;
      await supabase.from('payments').update({
        status: 'disputed',
      }).eq('external_payment_id', dispute.payment_intent);
      break;
    }
  }
  return new Response('OK');
};
```

### 2.3 Payment Release Trigger (Auto on Completion)

```sql
-- Trigger: release_payment_on_completion
CREATE OR REPLACE FUNCTION release_payment_on_completion()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    UPDATE payments
    SET status = 'released', released_at = NOW()
    WHERE booking_id = NEW.id AND status = 'held';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_release_payment
AFTER UPDATE ON bookings
FOR EACH ROW
WHEN (NEW.status = 'completed')
EXECUTE FUNCTION release_payment_on_completion();
```

---

## 3. Earnings Ledger (Immutable)

### 3.1 Earnings Creation Trigger

```sql
-- Trigger: create_earnings_on_completion
CREATE OR REPLACE FUNCTION create_earnings_on_completion()
RETURNS TRIGGER AS $$
DECLARE
  v_payment RECORD;
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    -- Get payment record
    SELECT * INTO v_payment FROM payments WHERE booking_id = NEW.id;
    
    IF FOUND THEN
      INSERT INTO pt_earnings (
        pt_id, booking_id, payment_id,
        gross_amount_cents,
        platform_commission_percent,
        platform_commission_fixed_cents,
        platform_commission_cents,
        net_amount_cents,
        is_released,
        released_at
      ) VALUES (
        NEW.pt_id, NEW.id, v_payment.id,
        NEW.price_cents,
        NEW.platform_commission_percent,
        NEW.platform_commission_fixed_cents,
        v_payment.platform_commission_cents,
        NEW.pt_earnings_cents,
        TRUE,
        NOW()
      );
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_earnings
AFTER UPDATE ON bookings
FOR EACH ROW
WHEN (NEW.status = 'completed')
EXECUTE FUNCTION create_earnings_on_completion();
```

### 3.2 Earnings States

| State | Description | Query |
|-------|-------------|-------|
| `is_released = false` | Payment still held (booking not completed) | `WHERE is_released = false` |
| `is_released = true, payout_id = null` | Available for payout | `WHERE is_released = true AND payout_id IS NULL` |
| `payout_id != null` | Included in payout batch | `WHERE payout_id = ?` |

### 3.3 PT Earnings Queries

```dart
// Unreleased (upcoming sessions)
final unreleased = await supabase
  .from('pt_earnings')
  .select('*, bookings(start_at, service_packages(name))')
  .eq('pt_id', ptId)
  .eq('is_released', false)
  .order('created_at');

// Available for withdrawal
final available = await supabase
  .from('pt_earnings')
  .select('sum(net_amount_cents) as total')
  .eq('pt_id', ptId)
  .eq('is_released', true)
  .isFilter('payout_id', null)
  .single();

// Payout history
final payouts = await supabase
  .from('payouts')
  .select()
  .eq('pt_id', ptId)
  .order('requested_at', ascending: false);
```

---

## 4. Payout Flow

### 4.1 Payout States

| Status | Meaning | Transition |
|--------|---------|------------|
| `pending` | PT requested, awaiting admin | PT inserts |
| `processing` | Admin reviewing/initiating transfer | Admin updates |
| `completed` | Transfer successful | Admin updates |
| `failed` | Transfer failed | Admin updates |
| `cancelled` | PT cancelled request | PT/Admin updates |

### 4.2 PT Requests Payout

```dart
// 1. Check minimum payout (from platform_settings)
final settings = await supabase
  .from('platform_settings')
  .select('value')
  .eq('key', 'payout_schedule')
  .single();
final minAmount = (settings['value'] as Map)['min_amount_cents'] as int;

// 2. Calculate available earnings
final available = await supabase
  .from('pt_earnings')
  .select('id, net_amount_cents')
  .eq('pt_id', ptId)
  .eq('is_released', true)
  .isFilter('payout_id', null);

final total = available.fold(0, (sum, e) => sum + e['net_amount_cents'] as int);

if (total < minAmount) throw 'Minimum payout not met';

// 3. Create payout request
final payout = await supabase.from('payouts').insert({
  'pt_id': ptId,
  'amount_cents': total,
  'period_start': periodStart,
  'period_end': periodEnd,
  'bank_account_name': bankName,
  'bank_account_number': bankAccount,
  'bank_name': bankBank,
  'status': 'pending',
}).select().single();

// 4. Link earnings to payout
final earningIds = available.map((e) => e['id']).toList();
await supabase.from('pt_earnings')
  .update({'payout_id': payout['id']})
  .inFilter('id', earningIds);
```

### 4.3 Admin Processes Payout

```dart
// 1. Get pending payouts
final pending = await supabase
  .from('payouts')
  .select('*, pt_profiles(bank_account_name, bank_account_number, bank_name)')
  .eq('status', 'pending')
  .order('requested_at');

// 2. Process (mark processing)
await supabase.from('payouts')
  .update({
    'status': 'processing',
    'processed_at': DateTime.now().toIso8601String(),
    'processed_by': adminId,
  })
  .eq('id', payoutId);

// 3. Execute bank transfer (external)
// ... bank API call ...

// 4. Complete
await supabase.from('payouts')
  .update({
    'status': 'completed',
    'completed_at': DateTime.now().toIso8601String(),
    'external_transfer_id': bankTransferRef,
    'external_transfer_data': bankResponseJson,
  })
  .eq('id', payoutId);
```

### 4.4 Scheduled Auto-Payout (pg_cron)

```sql
-- Run weekly on Monday (from platform_settings)
SELECT cron.schedule(
  'weekly-payouts',
  '0 9 * * 1', -- 9 AM Monday UTC
  $$
  DO $$
  DECLARE
    v_settings JSONB;
    v_min_amount INT;
    v_pt RECORD;
  BEGIN
    SELECT value INTO v_settings FROM platform_settings WHERE key = 'payout_schedule';
    v_min_amount := (v_settings->>'min_amount_cents')::INT;
    
    FOR v_pt IN
      SELECT pt_id, SUM(net_amount_cents) as total
      FROM pt_earnings
      WHERE is_released = TRUE AND payout_id IS NULL
      GROUP BY pt_id
      HAVING SUM(net_amount_cents) >= v_min_amount
    LOOP
      -- Create payout for each PT
      INSERT INTO payouts (pt_id, amount_cents, period_start, period_end, ...)
      VALUES (v_pt.pt_id, v_pt.total, ...);
      
      -- Link earnings
      UPDATE pt_earnings
      SET payout_id = currval('payouts_id_seq')
      WHERE pt_id = v_pt.pt_id AND is_released = TRUE AND payout_id IS NULL;
    END LOOP;
  END $$;
  $$
);
```

---

## 5. Cancellation & Refund Flow

### 5.1 Cancellation Policy (from platform_settings)

```json
{
  "free_window_hours": 24,
  "late_fee_percent": 50,
  "no_show_fee_percent": 100
}
```

### 5.2 Cancellation Fee Calculation

```dart
int calculateCancellationFee({
  required int priceCents,
  required DateTime sessionStart,
  required DateTime cancelledAt,
  required String cancelledBy, // 'client' or 'pt'
  required Map<String, dynamic> policy,
}) {
  final hoursUntilSession = sessionStart.difference(cancelledAt).inHours;
  final freeWindow = policy['free_window_hours'] as int;
  final lateFeePct = policy['late_fee_percent'] as int;
  final noShowFeePct = policy['no_show_fee_percent'] as int;
  
  if (cancelledBy == 'pt') {
    // PT cancels: full refund to client, no fee to client
    return 0; // PT bears cost (platform may charge PT separately)
  }
  
  if (hoursUntilSession <= 0) {
    // No-show or past session
    return (priceCents * noShowFeePct / 100).round();
  }
  
  if (hoursUntilSession <= freeWindow) {
    // Within free window
    return 0;
  }
  
  // Late cancellation
  return (priceCents * lateFeePct / 100).round();
}
```

### 5.3 Refund Processing

```dart
Future<void> processRefund({
  required String bookingId,
  required int refundAmountCents,
  required String reason,
}) async {
  // 1. Update booking
  await supabase.from('bookings').update({
    'status': 'refunded',
    'payment_status': 'refunded',
    'cancelled_at': DateTime.now().toIso8601String(),
    'cancellation_fee_cents': 0, // Already calculated
  }).eq('id', bookingId);

  // 2. Update payment
  await supabase.from('payments').update({
    'status': 'refunded',
    'refunded_at': DateTime.now().toIso8601String(),
    'refund_amount_cents': refundAmountCents,
    'refund_reason': reason,
  }).eq('booking_id', bookingId);

  // 3. Trigger Stripe refund via Edge Function
  await supabase.functions.invoke('stripe-refund', body: {
    'booking_id': bookingId,
    'amount_cents': refundAmountCents,
  });
}
```

---

## 6. Dispute Flow

### 6.1 Dispute States

| Status | Description |
|--------|-------------|
| `open` | Dispute filed, awaiting review |
| `under_review` | Admin investigating |
| `resolved_client` | Client wins (full/partial refund) |
| `resolved_pt` | PT wins (no refund) |
| `resolved_split` | Split decision (partial refund) |
| `escalated` | Escalated to higher authority |

### 6.2 Create Dispute

```dart
await supabase.from('disputes').insert({
  'booking_id': bookingId,
  'initiated_by': userId,
  'against_user_id': otherPartyId,
  'reason': 'Session not delivered as described',
  'description': 'PT cancelled last minute without notice',
  'evidence_urls': ['https://storage.supabase.co/...'],
  'status': 'open',
  'priority': 3,
});
```

### 6.3 Admin Resolves Dispute

```dart
// Client wins - full refund
await supabase.from('disputes').update({
  'status': 'resolved_client',
  'resolution': 'Full refund approved',
  'refund_amount_cents': bookingPriceCents,
  'resolved_at': DateTime.now().toIso8601String(),
  'resolved_by': adminId,
}).eq('id', disputeId);

// Trigger refund
await processRefund(bookingId: bookingId, refundAmountCents: bookingPriceCents, ...);

// PT wins - no refund
await supabase.from('disputes').update({
  'status': 'resolved_pt',
  'resolution': 'PT delivered service as agreed',
  'refund_amount_cents': 0,
  'resolved_at': DateTime.now().toIso8601String(),
  'resolved_by': adminId,
}).eq('id', disputeId);
```

---

## 7. No-Show Handling

### 7.1 Auto No-Show Detection (pg_cron)

```sql
-- Run every 15 minutes
SELECT cron.schedule(
  'detect-no-shows',
  '*/15 * * * *',
  $$
  DO $$
  DECLARE
    v_booking RECORD;
  BEGIN
    FOR v_booking IN
      SELECT id, pt_id, client_id, start_at, end_at
      FROM bookings
      WHERE status = 'in_progress'
      AND end_at < NOW() - INTERVAL '30 minutes' -- Grace period
    LOOP
      -- Determine who no-showed (requires check-in logic)
      -- For now: mark as completed, let dispute handle
      UPDATE bookings SET status = 'completed' WHERE id = v_booking.id;
    END LOOP;
  END $$;
  $$
);
```

### 7.2 Manual No-Show (PT Reports)

```dart
// PT reports client no-show
await supabase.from('bookings').update({
  'status': 'no_show_client',
  'actual_end_at': DateTime.now().toIso8601String(),
}).eq('id', bookingId).eq('pt_id', ptId);

// Client reports PT no-show
await supabase.from('bookings').update({
  'status': 'no_show_pt',
  'actual_end_at': DateTime.now().toIso8601String(),
}).eq('id', bookingId).eq('client_id', userId);
```

---

## 8. Edge Cases & Error Handling

### 8.1 Race Conditions

| Scenario | Prevention |
|----------|------------|
| Double booking same slot | `time_slots` unique index + `FOR UPDATE` in RPC |
| Payment captured but booking fails | Idempotency keys on Stripe; reconcile via webhook |
| Two payouts for same earnings | `payout_id` FK + `WHERE payout_id IS NULL` in batch |

### 8.2 Idempotency Keys

```dart
// Every payment intent gets unique key
final idempotencyKey = 'booking_${bookingId}_attempt_${attemptNumber}';

final paymentIntent = await stripe.paymentIntents.create({
  'amount': amountCents,
  'currency': 'vnd',
  'metadata': {'booking_id': bookingId},
}, idempotencyKey: idempotencyKey);
```

### 8.3 Reconciliation Job (Daily)

```sql
-- Find bookings with mismatched payment status
SELECT b.id, b.status, b.payment_status, p.status as payment_status
FROM bookings b
JOIN payments p ON p.booking_id = b.id
WHERE 
  (b.status = 'completed' AND p.status != 'released') OR
  (b.status = 'refunded' AND p.status != 'refunded') OR
  (b.status = 'cancelled_by_client' AND p.status NOT IN ('refunded', 'failed'));
```

---

## 9. Notification Triggers

### 9.1 Booking Events → Notifications

```sql
-- Trigger: notify_on_booking_events
CREATE OR REPLACE FUNCTION notify_on_booking_events()
RETURNS TRIGGER AS $$
DECLARE
  v_type notification_type;
  v_title TEXT;
  v_body TEXT;
  v_data JSONB;
BEGIN
  CASE NEW.status
    WHEN 'pending' THEN
      v_type := 'booking_request';
      v_title := 'New Booking Request';
      v_body := 'A client requested to book your session';
      v_data := jsonb_build_object('booking_id', NEW.id);
      INSERT INTO notifications (user_id, type, title, body, data, channel)
      VALUES (NEW.pt_id, v_type, v_title, v_body, v_data, 'in_app');
      
    WHEN 'confirmed' THEN
      v_type := 'booking_confirmed';
      v_title := 'Booking Confirmed';
      v_body := 'Your session has been confirmed';
      v_data := jsonb_build_object('booking_id', NEW.id);
      INSERT INTO notifications (user_id, type, title, body, data, channel)
      VALUES (NEW.client_id, v_type, v_title, v_body, v_data, 'in_app');
      
    WHEN 'completed' THEN
      v_type := 'session_completed';
      v_title := 'Session Completed';
      v_body := 'Your session has ended. Please leave a review!';
      v_data := jsonb_build_object('booking_id', NEW.id);
      INSERT INTO notifications (user_id, type, title, body, data, channel)
      VALUES (NEW.client_id, v_type, v_title, v_body, v_data, 'in_app');
      
      -- PT gets payment notification
      INSERT INTO notifications (user_id, type, title, body, data, channel)
      VALUES (NEW.pt_id, 'payment_received', 'Payment Released', 
        'Earnings from session have been released', v_data, 'in_app');
      
    WHEN 'cancelled_by_client' THEN
      INSERT INTO notifications (user_id, type, title, body, data, channel)
      VALUES (NEW.pt_id, 'booking_cancelled', 'Booking Cancelled',
        'Client cancelled the session', jsonb_build_object('booking_id', NEW.id), 'in_app');
        
    WHEN 'cancelled_by_pt' THEN
      INSERT INTO notifications (user_id, type, title, body, data, channel)
      VALUES (NEW.client_id, 'booking_cancelled', 'Booking Cancelled',
        'Trainer cancelled the session', jsonb_build_object('booking_id', NEW.id), 'in_app');
  END CASE;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_booking
AFTER UPDATE ON bookings
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION notify_on_booking_events();
```

---

## 10. Summary: Key Database Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `create_booking()` | RPC (manual) | Atomic slot lock + booking creation |
| `release_payment_on_completion()` | AFTER UPDATE bookings | Move payment held→released |
| `create_earnings_on_completion()` | AFTER UPDATE bookings | Insert pt_earnings row |
| `update_pt_rating_aggregate()` | AFTER INSERT reviews | Recalc avg_rating, total_reviews |
| `update_conversation_last_message()` | AFTER INSERT messages | Update conversation preview |
| `generate_time_slots()` | pg_cron daily + pt_availability UPDATE | Materialize slots for 90 days |
| `notify_on_booking_events()` | AFTER UPDATE bookings | Create in-app notifications |
| `detect-no-shows` | pg_cron 15min | Auto-complete stale in_progress |

---

## 11. Testing Checklist

### Booking Flow
- [ ] Client creates booking → slot marked booked
- [ ] PT confirms → status=confirmed, notification sent
- [ ] Session starts → status=in_progress
- [ ] Session ends → status=completed, payment released, earnings created
- [ ] Client cancels (within window) → status=cancelled_by_client, full refund
- [ ] Client cancels (late) → status=cancelled_by_client, fee applied
- [ ] PT cancels → status=cancelled_by_pt, full refund to client
- [ ] No-show detected → status=no_show_*, dispute possible

### Payment Flow
- [ ] Stripe webhook: succeeded → payment.held
- [ ] Stripe webhook: failed → payment.failed
- [ ] Booking completed → payment.released, earnings created
- [ ] Refund processed → payment.refunded, booking.refunded
- [ ] Chargeback → payment.disputed, dispute created

### Payout Flow
- [ ] PT requests payout → payout.pending, earnings linked
- [ ] Admin processes → payout.processing → payout.completed
- [ ] Auto-payout cron runs weekly

### Earnings Integrity
- [ ] Every completed booking = 1 pt_earnings row
- [ ] Sum(pt_earnings.net_amount) = Sum(bookings.pt_earnings_cents) for completed
- [ ] No duplicate earnings for same booking
- [ ] Unreleased earnings = pending/confirmed bookings

---

*Document version 1.0 — Update when triggers or flows change*