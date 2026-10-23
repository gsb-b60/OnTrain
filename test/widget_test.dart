import 'package:flutter_test/flutter_test.dart';
import 'package:ontrain/core/cancellation_policy.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/object/dispute.dart';
import 'package:ontrain/data/object/notification.dart';
import 'package:ontrain/data/object/payment.dart';
import 'package:ontrain/data/object/payout.dart';
import 'package:ontrain/data/object/pt_earnings.dart';
import 'package:ontrain/data/object/review.dart';
import 'package:ontrain/data/object/service_package.dart';
import 'package:ontrain/data/object/time_slot.dart';
import 'package:ontrain/data/enum/bookingStatus.dart';
import 'package:ontrain/data/enum/cancelReason.dart';
import 'package:ontrain/data/enum/disputeStatus.dart';
import 'package:ontrain/data/enum/earningsStatus.dart';
import 'package:ontrain/data/enum/paymentStatus.dart';
import 'package:ontrain/data/enum/payoutStatus.dart';

Booking _testBooking({
  String id = 'booking-1',
  BookingStatus status = BookingStatus.confirmed,
  DateTime? startAt,
  DateTime? endAt,
}) {
  final now = DateTime.now();
  return Booking(
    id: id,
    startAt: startAt ?? now.add(const Duration(days: 1)),
    endAt: endAt ?? now.add(const Duration(days: 1, hours: 1)),
    clientId: 'client-1',
    ptId: 'pt-1',
    priceCents: 100000,
    platformCommissionPercent: 15.0,
    platformCommissionFixedCents: 0,
    ptEarningsCents: 85000,
    status: status,
  );
}

Payment _testPayment({
  String id = 'payment-1',
  PaymentStatus status = PaymentStatus.held,
  String bookingId = 'booking-1',
}) {
  return Payment(
    id: id,
    bookingId: bookingId,
    clientId: 'client-1',
    amountCents: 100000,
    platformCommissionCents: 15000,
    ptAmountCents: 85000,
    paymentMethod: 'stripe',
    status: status,
    externalPaymentId: 'simulated_pi_123',
  );
}

PTEarnings _testEarnings({
  String id = 'earnings-1',
  bool isReleased = true,
  String? payoutId,
  String bookingId = 'booking-1',
}) {
  return PTEarnings(
    id: id,
    ptId: 'pt-1',
    bookingId: bookingId,
    paymentId: 'payment-1',
    amountCents: 100000,
    platformCommissionPercent: 15,
    platformCommissionFixedCents: 0,
    platformCommissionCents: 15000,
    netAmountCents: 85000,
    isReleased: isReleased,
    payoutId: payoutId,
    createdAt: DateTime.now(),
  );
}

Payout _testPayout({
  String id = 'payout-1',
  PayoutStatus status = PayoutStatus.pending,
}) {
  return Payout(
    id: id,
    ptId: 'pt-1',
    amountCents: 50000,
    status: status,
    bankAccountName: 'Test PT',
    bankAccountNumber: '123456789',
    bankName: 'Test Bank',
    bankBranch: 'Main Branch',
  );
}

Dispute _testDispute({
  String id = 'dispute-1',
  DisputeStatus status = DisputeStatus.open,
}) {
  return Dispute(
    id: id,
    bookingId: 'booking-1',
    raisedBy: 'client-1',
    againstUserId: 'pt-1',
    reason: 'Test dispute',
    status: status,
  );
}

Notification _testNotification({
  String id = 'notif-1',
  String type = 'booking_created',
  bool isRead = false,
}) {
  return Notification(
    id: id,
    userId: 'user-1',
    type: type,
    title: 'Test Notification',
    body: 'Test body',
    data: {'booking_id': 'booking-1'},
    isRead: isRead,
    createdAt: DateTime.now(),
  );
}

Review _testReview({String id = 'review-1', int rating = 5}) {
  return Review(
    id: id,
    bookingId: 'booking-1',
    clientId: 'client-1',
    ptId: 'pt-1',
    rating: rating,
    comment: 'Great session!',
    createdAt: DateTime.now(),
  );
}

void main() {
  group('CancellationPolicy', () {
    const policy = CancellationPolicy(
      freeUntilHoursBefore: 24,
      lateFeePercent: 50,
      noShowFeePercent: 100,
    );

    test('free cancel when > 24h before session', () {
      final now = DateTime.now();
      final sessionStart = now.add(const Duration(hours: 48));
      final (fee, reason) = policy.calculateFee(
        priceCents: 100000,
        sessionStart: sessionStart,
        cancelledAt: now,
        cancelledBy: 'client',
      );
      expect(fee, 0);
      expect(reason, 'free_cancel');
    });

    test('late cancel when ≤ 24h before session', () {
      final now = DateTime.now();
      final sessionStart = now.add(const Duration(hours: 2));
      final (fee, reason) = policy.calculateFee(
        priceCents: 100000,
        sessionStart: sessionStart,
        cancelledAt: now,
        cancelledBy: 'client',
      );
      expect(fee, 50000); // 50%
      expect(reason, 'late_cancel');
    });

    test('no-show client fee = 100%', () {
      final now = DateTime.now();
      final sessionStart = now.add(const Duration(hours: 1));
      final (fee, reason) = policy.calculateFee(
        priceCents: 100000,
        sessionStart: sessionStart,
        cancelledAt: now,
        cancelledBy: 'client',
        isNoShow: true,
      );
      expect(fee, 100000);
      expect(reason, 'no_show');
    });

    test('no-show PT fee = 100%', () {
      final now = DateTime.now();
      final sessionStart = now.add(const Duration(hours: 1));
      final (fee, reason) = policy.calculateFee(
        priceCents: 100000,
        sessionStart: sessionStart,
        cancelledAt: now,
        cancelledBy: 'pt',
        isNoShow: true,
      );
      expect(fee, 100000);
      expect(reason, 'no_show');
    });

    test('admin cancel = 0 fee', () {
      final now = DateTime.now();
      final sessionStart = now.add(const Duration(hours: 1));
      final (fee, reason) = policy.calculateFee(
        priceCents: 100000,
        sessionStart: sessionStart,
        cancelledAt: now,
        cancelledBy: 'admin',
      );
      expect(fee, 0);
      expect(reason, 'admin_cancel');
    });

    test('PT cancel before free window = 0 fee', () {
      final now = DateTime.now();
      final sessionStart = now.add(const Duration(hours: 48));
      final (fee, reason) = policy.calculateFee(
        priceCents: 100000,
        sessionStart: sessionStart,
        cancelledAt: now,
        cancelledBy: 'pt',
      );
      expect(fee, 0);
      expect(reason, 'free_cancel');
    });

    test('PT cancel within free window = 50% fee', () {
      final now = DateTime.now();
      final sessionStart = now.add(const Duration(hours: 12));
      final (fee, reason) = policy.calculateFee(
        priceCents: 100000,
        sessionStart: sessionStart,
        cancelledAt: now,
        cancelledBy: 'pt',
      );
      expect(fee, 50000);
      expect(reason, 'late_cancel');
    });
  });

  group('CancelReason enum', () {
    test('all values have correct dbValue and displayName', () {
      expect(CancelReason.rescheduling.dbValue, 'rescheduling');
      expect(CancelReason.rescheduling.displayName, 'Đổi lịch');
      expect(CancelReason.unexpectedWork.dbValue, 'unexpected_work');
      expect(CancelReason.unexpectedWork.displayName, 'Việc đột xuất');
      expect(CancelReason.weather.dbValue, 'weather');
      expect(CancelReason.weather.displayName, 'Thời tiết xấu');
      expect(CancelReason.others.dbValue, 'others');
      expect(CancelReason.others.displayName, 'Lý do khác');
    });

    test('fromString parses correctly', () {
      expect(
        CancelReason.fromString('rescheduling'),
        CancelReason.rescheduling,
      );
      expect(
        CancelReason.fromString('unexpected_work'),
        CancelReason.unexpectedWork,
      );
      expect(CancelReason.fromString('weather'), CancelReason.weather);
      expect(CancelReason.fromString('others'), CancelReason.others);
      expect(CancelReason.fromString('unknown'), CancelReason.others);
    });
  });

  group('DisputeStatus enum', () {
    test('all values have correct dbValue and displayName', () {
      expect(DisputeStatus.open.dbValue, 'open');
      expect(DisputeStatus.open.displayName, 'Đang mở');
      expect(DisputeStatus.resolvedClient.dbValue, 'resolved_client');
      expect(DisputeStatus.resolvedClient.displayName, 'Quyết định cho khách');
      expect(DisputeStatus.resolvedPt.dbValue, 'resolved_pt');
      expect(DisputeStatus.resolvedPt.displayName, 'Quyết định cho PT');
      expect(DisputeStatus.resolvedSplit.dbValue, 'resolved_split');
      expect(DisputeStatus.resolvedSplit.displayName, 'Chia sẻ');
      expect(DisputeStatus.refunded.dbValue, 'refunded');
      expect(DisputeStatus.refunded.displayName, 'Đã hoàn tiền');
    });

    test('fromString parses correctly', () {
      expect(DisputeStatus.fromString('open'), DisputeStatus.open);
      expect(
        DisputeStatus.fromString('resolved_client'),
        DisputeStatus.resolvedClient,
      );
      expect(DisputeStatus.fromString('resolved_pt'), DisputeStatus.resolvedPt);
      expect(
        DisputeStatus.fromString('resolved_split'),
        DisputeStatus.resolvedSplit,
      );
      expect(DisputeStatus.fromString('refunded'), DisputeStatus.refunded);
      expect(DisputeStatus.fromString('unknown'), DisputeStatus.open);
    });
  });

  group('Booking filter logic', () {
    test('upcoming filters confirmed and inProgress bookings in future', () {
      final now = DateTime.now();
      final mockBookings = [
        _testBooking(
          id: 'b1',
          status: BookingStatus.confirmed,
          startAt: now.add(const Duration(days: 1)),
        ),
        _testBooking(
          id: 'b2',
          status: BookingStatus.inProgress,
          startAt: now.add(const Duration(days: 2)),
        ),
        _testBooking(
          id: 'b3',
          status: BookingStatus.completed,
          startAt: now.subtract(const Duration(days: 1)),
        ),
        _testBooking(
          id: 'b4',
          status: BookingStatus.confirmed,
          startAt: now.subtract(const Duration(hours: 1)),
        ),
      ];

      final upcoming = mockBookings
          .where(
            (b) =>
                (b.status == BookingStatus.confirmed ||
                    b.status == BookingStatus.inProgress) &&
                b.startAt.isAfter(now),
          )
          .toList();
      expect(upcoming, hasLength(2));
      expect(upcoming.map((e) => e.id).toSet(), {'b1', 'b2'});
    });

    test('completed filters completed bookings', () {
      final mockBookings = [
        _testBooking(
          id: 'b1',
          status: BookingStatus.completed,
          startAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        _testBooking(
          id: 'b2',
          status: BookingStatus.confirmed,
          startAt: DateTime.now().add(const Duration(days: 1)),
        ),
      ];

      final completed = mockBookings
          .where((b) => b.status == BookingStatus.completed)
          .toList();
      expect(completed, hasLength(1));
      expect(completed.first.id, 'b1');
    });

    test('cancelled filters cancelled bookings', () {
      final mockBookings = [
        _testBooking(id: 'b1', status: BookingStatus.cancelledByClient),
        _testBooking(id: 'b2', status: BookingStatus.cancelledByPt),
        _testBooking(id: 'b3', status: BookingStatus.confirmed),
      ];

      final cancelled = mockBookings
          .where(
            (b) =>
                b.status == BookingStatus.cancelledByClient ||
                b.status == BookingStatus.cancelledByPt,
          )
          .toList();
      expect(cancelled, hasLength(2));
    });

    test('noShow filters no-show bookings', () {
      final mockBookings = [
        _testBooking(id: 'b1', status: BookingStatus.noShowClient),
        _testBooking(id: 'b2', status: BookingStatus.noShowPt),
        _testBooking(id: 'b3', status: BookingStatus.confirmed),
      ];

      final noShow = mockBookings
          .where(
            (b) =>
                b.status == BookingStatus.noShowClient ||
                b.status == BookingStatus.noShowPt,
          )
          .toList();
      expect(noShow, hasLength(2));
    });

    test('disputed filters disputed bookings', () {
      final mockBookings = [
        _testBooking(id: 'b1', status: BookingStatus.disputed),
        _testBooking(id: 'b2', status: BookingStatus.confirmed),
      ];

      final disputed = mockBookings
          .where((b) => b.status == BookingStatus.disputed)
          .toList();
      expect(disputed, hasLength(1));
    });
  });

  group('Model round-trip tests', () {
    test('Booking.fromMap parses all status strings correctly', () {
      for (final status in BookingStatus.values) {
        final map = {
          'id': 'test',
          'start_at': DateTime.now().toIso8601String(),
          'end_at': DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
          'client_id': 'c1',
          'pt_id': 'p1',
          'price_cents': 100000,
          'platform_commission_percent': 15.0,
          'platform_commission_fixed_cents': 0,
          'pt_earnings_cents': 85000,
          'status': status.dbValue,
        };
        final booking = Booking.fromMap(map);
        expect(booking.status, status);
      }
    });

    test('ServicePackage.fromMap parses correctly', () {
      final map = {
        'id': 'pkg-1',
        'pt_id': 'pt-1',
        'name': 'Personal Training 60min',
        'description': 'One-on-one session',
        'price_cents': 300000,
        'duration_minutes': 60,
        'is_active': true,
        'status': 'active',
      };
      final pkg = ServicePackage.fromMap(map);
      expect(pkg.id, 'pkg-1');
      expect(pkg.priceCents, 300000);
      expect(pkg.durationMinutes, 60);
    });

    test('TimeSlot.fromMap parses correctly', () {
      final startAt = DateTime.now().add(const Duration(days: 1));
      final endAt = startAt.add(const Duration(hours: 1));
      final map = {
        'id': 'slot-1',
        'pt_id': 'pt-1',
        'service_package_id': 'pkg-1',
        'start_at': startAt.toIso8601String(),
        'end_at': endAt.toIso8601String(),
        'timezone': 'UTC',
        'is_available': true,
        'is_booked': false,
      };
      final slot = TimeSlot.fromMap(map);
      expect(slot.id, 'slot-1');
      expect(slot.durationMinutes, 60);
      expect(slot.isAvailable, isTrue);
    });

    test('Payment.fromMap parses all status strings correctly', () {
      for (final status in PaymentStatus.values) {
        final map = {
          'id': 'test',
          'booking_id': 'booking-1',
          'client_id': 'client-1',
          'amount_cents': 100000,
          'platform_commission_cents': 15000,
          'pt_amount_cents': 85000,
          'payment_method': 'stripe',
          'status': status.dbValue,
          'external_payment_id': 'pi_test',
        };
        final payment = Payment.fromMap(map);
        expect(payment.status, status);
      }
    });

    test('Payment.fromMap parses correctly with all fields', () {
      final map = {
        'id': 'payment-1',
        'booking_id': 'booking-1',
        'client_id': 'client-1',
        'amount_cents': 300000,
        'platform_commission_cents': 45000,
        'pt_amount_cents': 255000,
        'payment_method': 'stripe',
        'status': 'held',
        'external_payment_id': 'pi_abc123',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      final payment = Payment.fromMap(map);
      expect(payment.id, 'payment-1');
      expect(payment.amountCents, 300000);
      expect(payment.platformCommissionCents, 45000);
      expect(payment.ptAmountCents, 255000);
      expect(payment.status, PaymentStatus.held);
    });

    test('Payment.toInsertMap excludes id and timestamps', () {
      final payment = _testPayment();
      final map = payment.toInsertMap();
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('created_at'), isFalse);
      expect(map.containsKey('updated_at'), isFalse);
      expect(map.containsKey('released_at'), isFalse);
      expect(map.containsKey('refunded_at'), isFalse);
      expect(map['booking_id'], 'booking-1');
      expect(map['status'], 'held');
    });

    test('PTEarnings derives status from is_released and payout_id', () {
      final pending = PTEarnings.fromMap({
        'id': 'pending',
        'pt_id': 'pt-1',
        'booking_id': 'booking-1',
        'gross_amount_cents': 100000,
        'net_amount_cents': 85000,
        'is_released': false,
        'payout_id': null,
      });
      expect(pending.status, EarningsStatus.pending);

      final available = PTEarnings.fromMap({
        'id': 'available',
        'pt_id': 'pt-1',
        'booking_id': 'booking-1',
        'gross_amount_cents': 100000,
        'net_amount_cents': 85000,
        'is_released': true,
        'payout_id': null,
      });
      expect(available.status, EarningsStatus.released);

      final paidOut = PTEarnings.fromMap({
        'id': 'paid-out',
        'pt_id': 'pt-1',
        'booking_id': 'booking-1',
        'gross_amount_cents': 100000,
        'net_amount_cents': 85000,
        'is_released': true,
        'payout_id': 'payout-1',
      });
      expect(paidOut.status, EarningsStatus.paidOut);
    });

    test('PTEarnings.fromMap parses correctly with all fields', () {
      final now = DateTime.now().toIso8601String();
      final map = {
        'id': 'earnings-1',
        'pt_id': 'pt-1',
        'booking_id': 'booking-1',
        'payment_id': 'payment-1',
        'gross_amount_cents': 300000,
        'platform_commission_percent': 15,
        'platform_commission_fixed_cents': 0,
        'platform_commission_cents': 45000,
        'net_amount_cents': 255000,
        'is_released': true,
        'payout_id': 'payout-1',
        'created_at': now,
        'released_at': now,
      };
      final earning = PTEarnings.fromMap(map);
      expect(earning.id, 'earnings-1');
      expect(earning.amountCents, 300000);
      expect(earning.platformCommissionCents, 45000);
      expect(earning.netAmountCents, 255000);
      expect(earning.isReleased, isTrue);
      expect(earning.payoutId, 'payout-1');
      expect(earning.status, EarningsStatus.paidOut);
    });

    test('PTEarnings.toInsertMap uses live schema columns', () {
      final earning = _testEarnings(payoutId: 'payout-1');
      final map = earning.toInsertMap();
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('created_at'), isFalse);
      expect(map.containsKey('released_at'), isFalse);
      expect(map.containsKey('status'), isFalse);
      expect(map.containsKey('paid_out_at'), isFalse);
      expect(map['pt_id'], 'pt-1');
      expect(map['is_released'], isTrue);
      expect(map['payout_id'], 'payout-1');
    });

    test('Payout.fromMap parses all status strings correctly', () {
      for (final status in PayoutStatus.values) {
        final map = {
          'id': 'test',
          'pt_id': 'pt-1',
          'amount_cents': 50000,
          'status': status.dbValue,
          'bank_account_name': 'Test PT',
          'bank_account_number': '123456789',
          'bank_name': 'Test Bank',
          'bank_branch': 'Main Branch',
          'requested_at': DateTime.now().toIso8601String(),
        };
        final payout = Payout.fromMap(map);
        expect(payout.status, status);
      }
    });

    test('Payout.fromMap parses correctly with all fields', () {
      final now = DateTime.now().toIso8601String();
      final map = {
        'id': 'payout-1',
        'pt_id': 'pt-1',
        'amount_cents': 100000,
        'status': 'completed',
        'period_start': '2026-10-01',
        'period_end': '2026-10-23',
        'bank_account_name': 'Test PT',
        'bank_account_number': '123456789',
        'bank_name': 'Test Bank',
        'bank_branch': 'Main Branch',
        'requested_at': now,
        'processed_at': now,
        'failure_reason': null,
      };
      final payout = Payout.fromMap(map);
      expect(payout.id, 'payout-1');
      expect(payout.amountCents, 100000);
      expect(payout.status, PayoutStatus.completed);
      expect(payout.periodStart, DateTime.parse('2026-10-01'));
      expect(payout.periodEnd, DateTime.parse('2026-10-23'));
      expect(payout.bankAccountName, 'Test PT');
      expect(payout.bankAccountNumber, '123456789');
      expect(payout.bankName, 'Test Bank');
    });

    test('Payout.toInsertMap excludes id and timestamps', () {
      final payout = _testPayout();
      final map = payout.toInsertMap();
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('requested_at'), isFalse);
      expect(map.containsKey('processed_at'), isFalse);
      expect(map['pt_id'], 'pt-1');
      expect(map['status'], 'pending');
    });

    test('Dispute.fromMap parses all status strings correctly', () {
      for (final status in DisputeStatus.values) {
        final map = {
          'id': 'test',
          'booking_id': 'booking-1',
          'raised_by': 'client-1',
          'against_user_id': 'pt-1',
          'reason': 'Test dispute',
          'status': status.dbValue,
          'created_at': DateTime.now().toIso8601String(),
        };
        final dispute = Dispute.fromMap(map);
        expect(dispute.status, status);
      }
    });

    test('Dispute.fromMap parses correctly with all fields', () {
      final now = DateTime.now().toIso8601String();
      final map = {
        'id': 'dispute-1',
        'booking_id': 'booking-1',
        'raised_by': 'client-1',
        'against_user_id': 'pt-1',
        'reason': 'Session not delivered',
        'status': 'resolved_client',
        'resolution_notes': 'Refund approved',
        'resolved_by': 'admin-1',
        'created_at': now,
        'resolved_at': now,
      };
      final dispute = Dispute.fromMap(map);
      expect(dispute.id, 'dispute-1');
      expect(dispute.bookingId, 'booking-1');
      expect(dispute.raisedBy, 'client-1');
      expect(dispute.againstUserId, 'pt-1');
      expect(dispute.reason, 'Session not delivered');
      expect(dispute.status, DisputeStatus.resolvedClient);
      expect(dispute.resolutionNotes, 'Refund approved');
      expect(dispute.resolvedBy, 'admin-1');
    });

    test('Dispute.toInsertMap excludes id and timestamps', () {
      final dispute = _testDispute();
      final map = dispute.toInsertMap();
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('created_at'), isFalse);
      expect(map.containsKey('resolved_at'), isFalse);
      expect(map['booking_id'], 'booking-1');
      expect(map['status'], 'open');
    });

    test('Notification.fromMap parses correctly with all fields', () {
      final now = DateTime.now().toIso8601String();
      final map = {
        'id': 'notif-1',
        'user_id': 'user-1',
        'type': 'booking_created',
        'title': 'Booking Created',
        'body': 'Your booking was created',
        'data': {'booking_id': 'booking-1'},
        'is_read': false,
        'created_at': now,
      };
      final notification = Notification.fromMap(map);
      expect(notification.id, 'notif-1');
      expect(notification.userId, 'user-1');
      expect(notification.type, 'booking_created');
      expect(notification.title, 'Booking Created');
      expect(notification.body, 'Your booking was created');
      expect(notification.data, {'booking_id': 'booking-1'});
      expect(notification.isRead, isFalse);
    });

    test('Notification.fromMap handles missing data field', () {
      final map = {
        'id': 'notif-1',
        'user_id': 'user-1',
        'type': 'booking_created',
        'title': 'Booking Created',
        'body': 'Your booking was created',
        'is_read': true,
        'created_at': DateTime.now().toIso8601String(),
      };
      final notification = Notification.fromMap(map);
      expect(notification.data, isNull);
      expect(notification.isRead, isTrue);
    });

    test('Notification.copyWith updates fields', () {
      final notification = _testNotification();
      final updated = notification.copyWith(isRead: true, title: 'Updated');
      expect(updated.isRead, isTrue);
      expect(updated.title, 'Updated');
      expect(updated.id, notification.id);
    });

    test('Review.fromMap parses correctly with all fields', () {
      final now = DateTime.now().toIso8601String();
      final map = {
        'id': 'review-1',
        'booking_id': 'booking-1',
        'client_id': 'client-1',
        'pt_id': 'pt-1',
        'rating': 5,
        'comment': 'Excellent!',
        'created_at': now,
      };
      final review = Review.fromMap(map);
      expect(review.id, 'review-1');
      expect(review.bookingId, 'booking-1');
      expect(review.clientId, 'client-1');
      expect(review.ptId, 'pt-1');
      expect(review.rating, 5);
      expect(review.comment, 'Excellent!');
    });

    test('Review.fromMap handles missing comment', () {
      final map = {
        'id': 'review-1',
        'booking_id': 'booking-1',
        'client_id': 'client-1',
        'pt_id': 'pt-1',
        'rating': 4,
        'created_at': DateTime.now().toIso8601String(),
      };
      final review = Review.fromMap(map);
      expect(review.comment, isNull);
      expect(review.rating, 4);
    });

    test('Review.toInsertMap excludes id and timestamps', () {
      final review = _testReview();
      final map = review.toInsertMap();
      expect(map.containsKey('id'), isFalse);
      expect(map.containsKey('created_at'), isFalse);
      expect(map['booking_id'], 'booking-1');
      expect(map['rating'], 5);
    });

    test('Review.copyWith updates fields', () {
      final review = _testReview(rating: 3);
      final updated = review.copyWith(rating: 5, comment: 'Updated');
      expect(updated.rating, 5);
      expect(updated.comment, 'Updated');
      expect(updated.id, review.id);
    });
  });
}
