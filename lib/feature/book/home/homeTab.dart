import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/data/object/ptSession.dart';
import 'package:ontrain/feature/PTDisplay/ptlistpage.dart';
import 'package:ontrain/feature/book/yoursessionpage.dart';
import 'package:ontrain/feature/profile/profilepage.dart';
import 'package:ontrain/feature/specialties/specialtiesScreen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                        icon: Icon(Icons.search),
                      ),
                    ],
                  ),
                  Spacer(),
                  SizedBox(
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
                            Consumer<AuthController>(
                              builder: (context, authController, child) {
                                return Text(
                                  authController.user?.name ?? 'Loading...',
                                );
                              },
                            ),
                          ],
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfilePage(isMainScreen: false),
                            ),
                          ),
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
                ],
              ),
              Divider(thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CateBtn(
                    title: "Favorite",
                    ico: Icons.favorite,
                    onCall: () {},
                  ),
                  CateBtn(
                    title: "PT",
                    ico: Icons.person,
                    onCall: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PTListpage()),
                      );
                    },
                  ),
                  CateBtn(title: "GYM", ico: Icons.map, onCall: () {}),
                  CateBtn(
                    title: "Specialties",
                    ico: Icons.school,
                    onCall: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpecialtiesScreen(),
                        ),
                      );
                    },
                  ),
                  CateBtn(
                    title: "Records",
                    ico: Icons.receipt_long,
                    onCall: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: TableCalendarEx()),
      ],
    );
  }
}

class CateBtn extends StatelessWidget {
  const CateBtn({
    super.key,
    required this.onCall,
    required this.title,
    required this.ico,
  });
  final VoidCallback onCall;
  final String title;
  final IconData ico;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {onCall()},
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: Icon(ico, color: AppColors.aquaTeal),
          ),
          Text(title, style: TextStyle(color: AppColors.aquaTeal)),
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
  List<PTSession> ptSessions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          eventLoader: (day) {
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YourSessionPage(),
                          ),
                        ),
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
