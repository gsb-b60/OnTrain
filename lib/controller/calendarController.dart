import 'package:flutter/material.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendarcontroller extends ChangeNotifier {
  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;
  List<Booking> _bookingsForSelectedDate = [];
  List<Booking> get bookingsForSelectedDate => _bookingsForSelectedDate;

  DateTime _focusedDay = DateTime.now();
  DateTime get focusedDay => _focusedDay;
  void setBookings(List<Booking> newBookings) {
    _bookings = newBookings;
    notifyListeners();
  }

  List<Booking> getBookingsForDate(DateTime date) {
    _focusedDay = date;
    final bookingsForDate = _bookings.where((booking) {
      return isSameDay(booking.startTime, date);
    }).toList();

    _bookingsForSelectedDate = bookingsForDate;
    notifyListeners();
    return bookingsForDate;
  }
}
