import 'package:flutter_test/flutter_test.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/object/service_package.dart';
import 'package:ontrain/data/object/time_slot.dart';
import 'package:ontrain/data/enum/bookingStatus.dart';

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

void main() {
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

      final upcoming = mockBookings.where((b) =>
          (b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.inProgress) &&
          b.startAt.isAfter(now)).toList();
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

      final completed = mockBookings.where((b) => b.status == BookingStatus.completed).toList();
      expect(completed, hasLength(1));
      expect(completed.first.id, 'b1');
    });

    test('cancelled filters cancelled bookings', () {
      final mockBookings = [
        _testBooking(
          id: 'b1',
          status: BookingStatus.cancelledByClient,
        ),
        _testBooking(
          id: 'b2',
          status: BookingStatus.cancelledByPt,
        ),
        _testBooking(
          id: 'b3',
          status: BookingStatus.confirmed,
        ),
      ];

      final cancelled = mockBookings
          .where((b) => b.status == BookingStatus.cancelledByClient || b.status == BookingStatus.cancelledByPt)
          .toList();
      expect(cancelled, hasLength(2));
    });

    test('noShow filters no-show bookings', () {
      final mockBookings = [
        _testBooking(
          id: 'b1',
          status: BookingStatus.noShowClient,
        ),
        _testBooking(
          id: 'b2',
          status: BookingStatus.noShowPt,
        ),
        _testBooking(
          id: 'b3',
          status: BookingStatus.confirmed,
        ),
      ];

      final noShow = mockBookings
          .where((b) => b.status == BookingStatus.noShowClient || b.status == BookingStatus.noShowPt)
          .toList();
      expect(noShow, hasLength(2));
    });

    test('disputed filters disputed bookings', () {
      final mockBookings = [
        _testBooking(
          id: 'b1',
          status: BookingStatus.disputed,
        ),
        _testBooking(
          id: 'b2',
          status: BookingStatus.confirmed,
        ),
      ];

      final disputed = mockBookings.where((b) => b.status == BookingStatus.disputed).toList();
      expect(disputed, hasLength(1));
    });
  });

  group('Model round-trip tests', () {
    test('Booking.fromMap parses all status strings correctly', () {
      for (final status in BookingStatus.values) {
        final map = {
          'id': 'test',
          'start_at': DateTime.now().toIso8601String(),
          'end_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
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
  });
}