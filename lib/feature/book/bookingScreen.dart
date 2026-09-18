import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/UI/favoriteBtn.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/bookingController.dart';
import 'package:ontrain/controller/calendarController.dart';
import 'package:ontrain/controller/ptController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/data/object/ptSession.dart';
import 'package:ontrain/feature/book/yoursessionpage.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.pt});
  final PT pt;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<Bookingcontroller>().fetchBookingsForPT(widget.pt.id);
  }

  List<Booking> ptSessions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 40),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: AppGradients.brand),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios, color: AppColors.light),
                    ),
                    Expanded(
                      child: Container(
                        height: 33,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.greyAqua,
                        ),
                        child: Center(
                          child: Text(
                            widget.pt.name,
                            style: TextStyle(
                              color: AppColors.aquaTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // IconButton.filled(
                    //   color: AppColors.aquaTeal,
                    //   style: IconButton.styleFrom(
                    //     backgroundColor: AppColors.greyAqua,
                    //   ),
                    //   iconSize: 16,
                    //   visualDensity: VisualDensity.compact,
                    //   onPressed: () {},
                    //   icon: Icon(Icons.call),
                    // ),
                    // IconButton.filled(
                    //   color: AppColors.aquaTeal,
                    //   style: IconButton.styleFrom(
                    //     backgroundColor: AppColors.greyAqua,
                    //   ),
                    //   iconSize: 16,
                    //   visualDensity: VisualDensity.compact,
                    //   onPressed: () {},
                    //   icon: Icon(Icons.chat),
                    // ),
                    // IconButton.filled(
                    //   color: AppColors.aquaTeal,
                    //   style: IconButton.styleFrom(
                    //     backgroundColor: AppColors.greyAqua,
                    //   ),
                    //   iconSize: 16,
                    //   visualDensity: VisualDensity.compact,
                    //   onPressed: () {},
                    //   icon: Icon(Icons.question_mark),
                    // ),
                    favoriteIconBtn(pt: widget.pt),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<Bookingcontroller>(
              builder: (context, bookingController, child) {
                return TableCanlendarBooking(
                  ptSessions: bookingController.ptBookings,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TableCanlendarBooking extends StatefulWidget {
  const TableCanlendarBooking({super.key, required this.ptSessions});
  final List<Booking> ptSessions;

  @override
  State<TableCanlendarBooking> createState() => _TableCanlendarBookingState();
}

class _TableCanlendarBookingState extends State<TableCanlendarBooking> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<DateTime> hours = [
    DateTime(0, 0, 0, 5),
    DateTime(0, 0, 0, 7),
    DateTime(0, 0, 0, 9),
    DateTime(0, 0, 0, 11),
    DateTime(0, 0, 0, 13),
    DateTime(0, 0, 0, 15),
    DateTime(0, 0, 0, 17),
    DateTime(0, 0, 0, 19),
    DateTime(0, 0, 0, 19),
    DateTime(0, 0, 0, 19),
    DateTime(0, 0, 0, 19),
  ];
  bool isHourBooked(DateTime hourSlot) {
    return widget.ptSessions.any((session) {
      final start = session.startTime;
      final end = session.endTime;

      if (start == null || end == null) {
        return false;
      }

      if (!isSameDay(start, _selectedDay)) {
        return false;
      }

      return hourSlot.hour >= start.hour && hourSlot.hour < end.hour;
    });
  }

  /// Confirms with the user, inserts the booking, and reports the outcome.
  Future<void> _confirmAndInsert(DateTime hourSlot) async {
    final time = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      hourSlot.hour,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm booking"),
        content: Text(
          "Book ${time.hour}:00 with this PT on "
          "${DateFormat('dd/MM/yyyy').format(time)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    final ok = await context.read<Bookingcontroller>().insertBooking(time);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? "Session booked for ${DateFormat('hh:mm a').format(time)}"
              : "Booking failed: ${context.read<Bookingcontroller>().error ?? 'unknown error'}",
        ),
      ),
    );
  }

  @override
  void initState() {
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          eventLoader: (day) {
            if (widget.ptSessions.any(
              (session) => isSameDay(session.startTime, day),
            )) {
              return widget.ptSessions
                  .where((session) => isSameDay(session.startTime, day))
                  .toList();
            }

            return [];
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          weekNumbersVisible: true,
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: AppColors.aquaTeal,
              shape: BoxShape.circle,
            ),
            markerSize: 6,
            todayDecoration: BoxDecoration(
              color: AppColors.mintLight,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.aquaTeal,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(color: AppColors.black),
            weekendTextStyle: TextStyle(color: AppColors.aquaTeal),
            outsideTextStyle: TextStyle(color: Colors.grey),
          ),
          headerStyle: HeaderStyle(
            formatButtonShowsNext: false,
            formatButtonVisible: true,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: AppColors.aquaTeal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: AppColors.aquaTeal,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: AppColors.aquaTeal,
            ),
            decoration: BoxDecoration(),
          ),
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          headerVisible: true,

          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(hours.length, (index) {
            return BookingBlock(
              hours: hours[index],
              isBooked: isHourBooked(hours[index]),
              onTap: () => _confirmAndInsert(hours[index]),
            );
          }),
        ),
        // Divider(),
        // Text(
        //   "PT NAME",
        //   style: TextStyle(
        //     color: AppColors.aquaTeal,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // Expanded(
        //   child: ListView.builder(
        //     itemBuilder: (context, index) {
        //       return GestureDetector(
        //         onTap: () => Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => YourSessionPage()),
        //         ),
        //         child: ListTile(
        //           leading: Icon(
        //             Icons.check_box_outline_blank_outlined,
        //             color: AppColors.aquaTeal,
        //           ),
        //           // title: Text(
        //           //   "${DateFormat('H:mm').format(ptSessions[index].startTime)} - ${DateFormat('H:mm').format(ptSessions[index].endTime)}  ${DateFormat('dd-MM-yyyy').format(ptSessions[index].endTime)}",
        //           // ),
        //           //subtitle: Text(ptSessions[index].notes),
        //           trailing: Icon(Icons.star_outline, color: AppColors.aquaTeal),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

class BookingBlock extends StatelessWidget {
  const BookingBlock({
    super.key,
    required this.hours,
    required this.isBooked,
    this.onTap,
  });
  final bool isBooked;
  final DateTime hours;

  /// Invoked when a free slot is tapped. When null, tapping navigates to the
  /// booking-details screen (legacy behaviour).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: isBooked
            ? null
            : (onTap ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            YourSessionPage(booking: Booking(startTime: hours)),
                      ),
                    );
                  }),
        child: Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: !isBooked ? AppColors.aquaTeal : AppColors.light,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "${hours.hour}:${hours.minute.toString().padLeft(2, '0')}",
            style: TextStyle(
              color: !isBooked ? AppColors.light : AppColors.aquaTeal,
            ),
          ),
        ),
      ),
    );
  }
}
