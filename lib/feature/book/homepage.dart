import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/feature/book/ptlistpage.dart';
import 'package:ontrain/feature/book/yoursessionpage.dart';
import 'package:table_calendar/table_calendar.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<PT> pts = [
      PT(
        id: 1,
        name: "Jane Doe",
        Pnum: "123-456-7890",
        email: "",
        state: PTState.accepted,
        address: "123 Main St, City, Country",
        createdAt: DateTime.now(),
      ),
      PT(
        id: 1,
        name: "Jane Doe",
        Pnum: "123-456-7890",
        email: "",
        state: PTState.accepted,
        address: "123 Main St, City, Country",
        createdAt: DateTime.now(),
      ),
      PT(
        id: 1,
        name: "Jane Doe",
        Pnum: "123-456-7890",
        email: "",
        state: PTState.accepted,
        address: "123 Main St, City, Country",
        createdAt: DateTime.now(),
      ),
      PT(
        id: 1,
        name: "Jane Doe",
        Pnum: "123-456-7890",
        email: "",
        state: PTState.accepted,
        address: "123 Main St, City, Country",
        createdAt: DateTime.now(),
      ),
    ];
    return Scaffold(
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(23.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () {},
                          icon: Icon(Icons.notifications_none_sharp),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {},
                          icon: Icon(Icons.settings),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {},
                          icon: Icon(Icons.search),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      height: 40,
                      width: 170,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Hi, WelcomeBack",
                                style: TextStyle(color: AppColors.aquaTeal),
                              ),
                              Text("Jane Doe"),
                            ],
                          ),
                          Spacer(),
                          GestureDetector(
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                "assets/PXL_20251014_011048644~2.jpg",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Category",
                      style: TextStyle(
                        color: AppColors.aquaTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "See All",
                      style: TextStyle(
                        color: AppColors.aquaTeal,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.aquaTeal,
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => {},
                      child: Container(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.favorite_border),
                              color: AppColors.aquaTeal,
                            ),
                            Text(
                              "Favorite",
                              style: TextStyle(color: AppColors.aquaTeal),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>PTListpage(pts: pts)))
                      },
                      child: Container(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.person),
                              color: AppColors.aquaTeal,
                            ),
                            Text(
                              "PT",
                              style: TextStyle(color: AppColors.aquaTeal),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {},
                      child: Container(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              color: AppColors.aquaTeal,
                              icon: Icon(Icons.map),
                            ),
                            Text(
                              "GYM",
                              style: TextStyle(color: AppColors.aquaTeal),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {},
                      child: Container(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              color: AppColors.aquaTeal,
                              icon: Icon(Icons.school),
                            ),
                            Text(
                              "Specialties",
                              style: TextStyle(color: AppColors.aquaTeal),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {},
                      child: Container(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              color: AppColors.aquaTeal,
                              icon: Icon(Icons.receipt_long_rounded),
                            ),
                            Text(
                              "Records",
                              style: TextStyle(color: AppColors.aquaTeal),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: Container(child: TableCalendarEx())),
        ],
      ),
    );
  }
}

class TableCalendarEx extends StatefulWidget {
  const TableCalendarEx({super.key});

  @override
  State<TableCalendarEx> createState() => _TableCalendarExState();
}

class _TableCalendarExState extends State<TableCalendarEx> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          eventLoader: (day) {
            // if (day.weekday == DateTime.tuesday) {
            //   return ['Gym', 'Study'];
            // }
            if (ptSessions.any(
              (session) => isSameDay(session.startTime, day),
            )) {
              return ptSessions
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
          headerVisible: true,
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
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
        Expanded(
          child: Container(
            child: _selectedDay == null
                ? Center()
                : ListView.builder(
                    itemCount: ptSessions
                        .where(
                          (session) =>
                              isSameDay(session.startTime, _selectedDay!),
                        )
                        .length,
                    itemBuilder: (context, index) {
                      List<PTSession> selectedSessions = ptSessions
                          .where(
                            (session) =>
                                isSameDay(session.startTime, _selectedDay!),
                          )
                          .toList();
                      selectedSessions.sort(
                        (a, b) => a.startTime.compareTo(b.startTime),
                      );
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>YourSessionPage())),
                        child: ListTile(
                          leading: Icon(
                            Icons.check_box_outline_blank_outlined,
                            color: AppColors.aquaTeal,
                          ),
                          title: Text(
                            "${DateFormat('H:mm').format(selectedSessions[index].startTime)} - ${DateFormat('H:mm').format(selectedSessions[index].endTime)}  ${DateFormat('dd-MM-yyyy').format(selectedSessions[index].endTime)}",
                          ),
                          subtitle: Text(selectedSessions[index].notes),
                          trailing: Icon(
                            Icons.star_outline,
                            color: AppColors.aquaTeal,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
