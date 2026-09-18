import 'package:flutter/widgets.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/calendarController.dart';
import 'package:ontrain/controller/paymentController.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/data/object/service_package.dart';
import 'package:ontrain/data/object/time_slot.dart';
import 'package:ontrain/data/enum/bookingStatus.dart';
import 'package:ontrain/model/stateEnum.dart';
import 'package:ontrain/repo/bookingRepository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Bookingcontroller extends ChangeNotifier {
  final BookingRepository repository;
  final AuthController authController;
  final Calendarcontroller calendarController;
  final Paymentcontroller paymentController;

  Bookingcontroller({
    required this.repository,
    required this.authController,
    required this.calendarController,
    required this.paymentController,
  });

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;
  List<Booking> _ptBookings = [];
  List<Booking> get ptBookings => _ptBookings;
  ViewState _state = ViewState.idle;
  ViewState get state => _state;
  String? _error;
  String? get error => _error;

  String? _ptID;
  String? get ptID => _ptID;

  List<ServicePackage> _servicePackages = [];
  List<ServicePackage> get servicePackages => _servicePackages;

  List<TimeSlot> _slotsForDate = [];
  List<TimeSlot> get slotsForDate => _slotsForDate;

  Future<List<Booking>> fetchBookingsForPT(String ptId) async {
    _ptID = ptId;
    _state = ViewState.loading;
    _error = null;
    notifyListeners();
    final result = await repository.fetchBookingByPTID(ptId);
    if (result.isSuccess) {
      _ptBookings = result.data ?? [];
      _state = ViewState.success;
    } else {
      _ptBookings = [];
      _error = result.error?.message;
      _state = ViewState.error;
    }
    notifyListeners();
    return _ptBookings;
  }

  Future<List<Booking>> fetchBookingsForClient(String clientId) async {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();
    final result = await repository.fetchBookingsByClientId(clientId);
    if (result.isSuccess) {
      _bookings = result.data ?? [];
      _state = ViewState.success;
    } else {
      _bookings = [];
      _error = result.error?.message;
      _state = ViewState.error;
    }
    notifyListeners();
    return _bookings;
  }

  Future<List<ServicePackage>> fetchServicePackages(String ptId) async {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();
    final result = await repository.fetchServicePackages(ptId);
    if (result.isSuccess) {
      _servicePackages = result.data ?? [];
      _state = ViewState.success;
    } else {
      _servicePackages = [];
      _error = result.error?.message;
      _state = ViewState.error;
    }
    notifyListeners();
    return _servicePackages;
  }

  Future<List<TimeSlot>> fetchAvailableSlotsForPT({
    required String ptId,
    required DateTime date,
  }) async {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();
    final result = await repository.fetchSlotsForDate(ptId: ptId, date: date);
    if (result.isSuccess) {
      _slotsForDate = result.data ?? [];
      _state = ViewState.success;
    } else {
      _slotsForDate = [];
      _error = result.error?.message;
      _state = ViewState.error;
    }
    notifyListeners();
    return _slotsForDate;
  }

  Map<String, List<TimeSlot>> getSlotsGroupedByPackage() {
    final Map<String, List<TimeSlot>> grouped = {};
    for (final slot in _slotsForDate) {
      final pkgName = slot.servicePackage?.name ?? 'Unknown';
      grouped.putIfAbsent(pkgName, () => []).add(slot);
    }
    return grouped;
  }

  /// Creates a booking from a time slot using the atomic RPC.
  /// Returns true on success, false on failure.
  Future<bool> createBookingFromSlot(String slotId) async {
    final clientId = authController.user?.id;
    if (clientId == null) {
      _error = 'Login required to book a session';
      notifyListeners();
      return false;
    }

    final slot = _slotsForDate.firstWhere(
      (s) => s.id == slotId,
      orElse: () => TimeSlot(
        id: '',
        ptId: '',
        servicePackageId: '',
        startAt: DateTime.now(),
        endAt: DateTime.now().add(const Duration(hours: 1)),
        timezone: 'UTC',
        isAvailable: false,
        isBooked: false,
      ),
    );

    if (slot.id.isEmpty) {
      _error = 'Slot not found';
      notifyListeners();
      return false;
    }

    if (!slot.isAvailable || slot.isBooked) {
      _error = 'Slot is no longer available';
      notifyListeners();
      return false;
    }

    final pkg = slot.servicePackage;
    if (pkg == null) {
      _error = 'Service package not found for slot';
      notifyListeners();
      return false;
    }

    final priceCents = pkg.priceCents;
    const platformCommissionPercent = 15.0;
    const platformCommissionFixedCents = 0;
    final platformCommissionCents =
        (priceCents * platformCommissionPercent / 100).round() + platformCommissionFixedCents;
    final ptEarningsCents = priceCents - platformCommissionCents;

    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    final result = await repository.createBooking(Booking(
      startAt: slot.startAt,
      endAt: slot.endAt,
      clientId: clientId,
      ptId: slot.ptId,
      servicePackageId: slot.id,
      priceCents: priceCents,
      platformCommissionPercent: platformCommissionPercent,
      platformCommissionFixedCents: platformCommissionFixedCents,
      ptEarningsCents: ptEarningsCents,
      clientNotes: 'Booked via app',
    ));

    if (result.isSuccess) {
      final booking = result.data!;

      // Create held payment record
      await paymentController.createPaymentForBooking(
        bookingId: booking.id!,
        amountCents: priceCents,
        platformCommissionCents: platformCommissionCents,
        ptAmountCents: ptEarningsCents,
      );

      _state = ViewState.success;
      _slotsForDate = _slotsForDate.map((s) {
        if (s.id == slotId) {
          return s.copyWith(isBooked: true, bookingId: booking.id);
        }
        return s;
      }).toList();
      await fetchBookingsForPT(slot.ptId);
      notifyListeners();
      return true;
    } else {
      _state = ViewState.error;
      _error = result.error?.message;
      notifyListeners();
      return false;
    }
  }

  List<Booking> get upcoming => _bookings
      .where((b) =>
          (b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.inProgress) &&
          b.startAt.isAfter(DateTime.now()))
      .toList();

  List<Booking> get completed => _bookings
      .where((b) => b.status == BookingStatus.completed)
      .toList();

  List<Booking> get cancelled => _bookings
      .where((b) =>
          b.status == BookingStatus.cancelledByClient ||
          b.status == BookingStatus.cancelledByPt)
      .toList();

  List<Booking> get disputed => _bookings
      .where((b) => b.status == BookingStatus.disputed)
      .toList();

  List<Booking> get noShow => _bookings
      .where((b) =>
          b.status == BookingStatus.noShowClient ||
          b.status == BookingStatus.noShowPt)
      .toList();

  /// Returns true when the booking was inserted successfully, so the UI can
  /// show a confirmation or surface the failure message.
  Future<bool> insertBooking({
    required DateTime startAt,
    required DateTime endAt,
    required String servicePackageId,
    required int priceCents,
    required double platformCommissionPercent,
    required int platformCommissionFixedCents,
    required int ptEarningsCents,
  }) async {
    final clientId = authController.user?.id;
    if (clientId == null) {
      _error = 'Login required to book a session';
      notifyListeners();
      return false;
    }
    if (servicePackageId.isEmpty) {
      _error = 'Service package required';
      notifyListeners();
      return false;
    }

    final booking = Booking(
      startAt: startAt,
      endAt: endAt,
      clientId: clientId,
      ptId: _ptID ?? '',
      servicePackageId: servicePackageId,
      priceCents: priceCents,
      platformCommissionPercent: platformCommissionPercent,
      platformCommissionFixedCents: platformCommissionFixedCents,
      ptEarningsCents: ptEarningsCents,
      clientNotes: 'Booked via app',
    );

    final result = await repository.createBooking(booking);
    if (result.isSuccess) {
      _state = ViewState.success;
      _ptBookings = [..._ptBookings, result.data!];
      notifyListeners();
      return true;
    } else {
      _state = ViewState.error;
      _error = result.error?.message;
      notifyListeners();
      return false;
    }
  }
}