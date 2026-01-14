import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/feature/book/yoursessionpage.dart';
import 'package:table_calendar/table_calendar.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
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
                            "PT NAME",
                            style: TextStyle(
                              color: AppColors.aquaTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      color: AppColors.aquaTeal,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.greyAqua,
                      ),
                      iconSize: 16,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {},
                      icon: Icon(Icons.call),
                    ),
                    IconButton.filled(
                      color: AppColors.aquaTeal,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.greyAqua,
                      ),
                      iconSize: 16,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {},
                      icon: Icon(Icons.chat),
                    ),
                    IconButton.filled(
                      color: AppColors.aquaTeal,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.greyAqua,
                      ),
                      iconSize: 16,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {},
                      icon: Icon(Icons.question_mark),
                    ),
                    IconButton.filled(
                      color: AppColors.aquaTeal,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.greyAqua,
                      ),
                      iconSize: 16,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {},
                      icon: Icon(Icons.favorite),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: TableCanlendarBooking()),
        ],
      ),
    );
  }
}

class TableCanlendarBooking extends StatefulWidget {
  const TableCanlendarBooking({super.key});

  @override
  State<TableCanlendarBooking> createState() => _TableCanlendarBookingState();
}

class _TableCanlendarBookingState extends State<TableCanlendarBooking> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<PTSession> ptSessions = [
    PTSession(
      id: 1,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 5),
      startTime: DateTime(2026, 1, 5, 7, 0),
      endTime: DateTime(2026, 1, 5, 9, 0),
      notes: 'note for session 1',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 2,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 6, 18, 0),
      endTime: DateTime(2026, 1, 6, 19, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 3,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 8, 18, 0),
      endTime: DateTime(2026, 1, 8, 19, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 4,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 8, 9, 0),
      endTime: DateTime(2026, 1, 8, 11, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 5,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 9, 18, 0),
      endTime: DateTime(2026, 1, 9, 20, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 6,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 10, 18, 0),
      endTime: DateTime(2026, 1, 10, 20, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 7,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 12, 18, 0),
      endTime: DateTime(2026, 1, 12, 19, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
    PTSession(
      id: 8,
      ptContranstId: 101,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 13, 18, 0),
      endTime: DateTime(2026, 1, 13, 19, 0),
      notes: 'Note for session 2',
      createdAt: DateTime.now(),
    ),
  ];
  List<String> hours = [
    "5:00",
    "7:00",
    "9:00",
    "11:00",
    "13:00",
    "15:00",
    "17:00",
    "19:00",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
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
          focusedDay: DateTime.now(),
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
          children: List.generate(
            hours.length,
            (index) =>
                ElevatedButton(onPressed: () {}, child: Text(hours[index])),
          ),
        ),
        Divider(),
        Text(
          "PT NAME",
          style: TextStyle(
            color: AppColors.aquaTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Expanded(
        //   child: ListView.builder(
        //     itemBuilder: (context, index) {
        //       return GestureDetector(
        //         onTap: () => Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => YourSessionPage(),
        //           ),
        //         ),
        //         child: ListTile(
        //           leading: Icon(
        //             Icons.check_box_outline_blank_outlined,
        //             color: AppColors.aquaTeal,
        //           ),
        //           title: Text(
        //             "${DateFormat('H:mm').format(ptSessions[index].startTime)} - ${DateFormat('H:mm').format(ptSessions[index].endTime)}  ${DateFormat('dd-MM-yyyy').format(ptSessions[index].endTime)}",
        //           ),
        //           subtitle: Text(ptSessions[index].notes),
        //           trailing: Icon(
        //             Icons.star_outline,
        //             color: AppColors.aquaTeal,
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}
