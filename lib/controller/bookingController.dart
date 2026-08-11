import 'package:flutter/widgets.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/calendarController.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/model/stateEnum.dart';
import 'package:ontrain/repo/bookingRepository.dart';

class Bookingcontroller extends ChangeNotifier {
  BookingRepository repository;
  AuthController authController;
  Calendarcontroller calendarController;

  Bookingcontroller(this.repository, this.authController,  this.calendarController);

  final List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;
  List<Booking> _ptBookings = [];
  List<Booking> get ptBookings => _ptBookings;
  ViewState _state = ViewState.idle;
  ViewState get state => _state;
  String? _error;
  String? get error => _error;

  String? _ptID;
  String? get ptID => _ptID;


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

  /// Returns true when the booking was inserted successfully, so the UI can
  /// show a confirmation or surface the failure message.
  Future<bool> insertBooking(DateTime time) async {
    final clientId = authController.user?.id;
    if (clientId == null || _ptID == null) {
      _error = "Login required to book a session";
      notifyListeners();
      return false;
    }
    Booking booking = Booking(
      startTime: time,
      endTime: time.add(const Duration(hours: 1)),
      clientId: clientId,
      ptId: _ptID,
      notes: "Booked via app",
    );

    final result = await repository.insertBooking(booking);
    if (result.isSuccess) {
      _state = ViewState.success;
      // Reflect the new booking in the list immediately.
      _ptBookings = [..._ptBookings, booking];
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
