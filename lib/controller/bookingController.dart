import 'package:flutter/widgets.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/repo/bookingRepository.dart';

class Bookingcontroller extends ChangeNotifier{
  BookingRepository repository;
  Bookingcontroller(this.repository);

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;
  List<Booking> _ptBookings = [];
  List<Booking> get ptBookings => _ptBookings;

  Future<List<Booking>> fetchBookingsForPT(String ptId) async {
    final result = await repository.fetchBookingByPTID(ptId);
    if (result.isSuccess) {
      _bookings = result.data!;
    } else {
      _bookings = [];
    }
    notifyListeners();
    return _bookings;
  }


}