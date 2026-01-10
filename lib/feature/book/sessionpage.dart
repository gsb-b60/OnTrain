import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/feature/book/cancelsess.dart';
import 'package:ontrain/feature/book/review.dart';
import 'package:ontrain/feature/book/yoursessionpage.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  int pageIndex = 1;
  final List<PTSession> sessions = [
    PTSession(
      id: 1,
      ptContranstId: 1001,
      sessionDate: DateTime(2026, 1, 1),
      startTime: DateTime(2026, 1, 1, 18, 0),
      endTime: DateTime(2026, 1, 1, 19, 0),
      notes: "Upper body strength",
      createdAt: DateTime(2025, 12, 20),
    ),
    PTSession(
      id: 2,
      ptContranstId: 1001,
      sessionDate: DateTime(2026, 1, 3),
      startTime: DateTime(2026, 1, 3, 18, 0),
      endTime: DateTime(2026, 1, 3, 19, 0),
      notes: "Lower body strength",
      createdAt: DateTime(2025, 12, 20),
    ),
    PTSession(
      id: 3,
      ptContranstId: 1001,
      sessionDate: DateTime(2026, 1, 5),
      startTime: DateTime(2026, 1, 5, 18, 0),
      endTime: DateTime(2026, 1, 5, 19, 0),
      notes: "Push workout",
      createdAt: DateTime(2025, 12, 20),
    ),
    PTSession(
      id: 4,
      ptContranstId: 1001,
      sessionDate: DateTime(2026, 1, 7),
      startTime: DateTime(2026, 1, 7, 18, 0),
      endTime: DateTime(2026, 1, 7, 19, 0),
      notes: "Pull workout",
      createdAt: DateTime(2025, 12, 20),
    ),
    PTSession(
      id: 5,
      ptContranstId: 1001,
      sessionDate: DateTime(2026, 1, 9),
      startTime: DateTime(2026, 1, 9, 18, 0),
      endTime: DateTime(2026, 1, 9, 19, 0),
      notes: "Core & stability",
      createdAt: DateTime(2025, 12, 20),
    ),
    PTSession(
      id: 6,
      ptContranstId: 1001,
      sessionDate: DateTime(2026, 1, 11),
      startTime: DateTime(2026, 1, 11, 18, 0),
      endTime: DateTime(2026, 1, 11, 19, 0),
      notes: "Hypertrophy focus",
      createdAt: DateTime(2025, 12, 20),
    ),
    PTSession(
      id: 7,
      ptContranstId: 1001,
      sessionDate: DateTime(2026, 1, 13),
      startTime: DateTime(2026, 1, 13, 18, 0),
      endTime: DateTime(2026, 1, 13, 19, 0),
      notes: "Strength progression",
      createdAt: DateTime(2025, 12, 20),
    ),
    PTSession(
      id: 8,
      ptContranstId: 1001,
      sessionDate: DateTime(2026, 1, 15),
      startTime: DateTime(2026, 1, 15, 18, 0),
      endTime: DateTime(2026, 1, 15, 19, 0),
      notes: "Conditioning",
      createdAt: DateTime(2025, 12, 20),
    ),
    PTSession(
      id: 9,
      ptContranstId: 1001,
      sessionDate: DateTime(2026, 1, 17),
      startTime: DateTime(2026, 1, 17, 18, 0),
      endTime: DateTime(2026, 1, 17, 19, 0),
      notes: "Full body workout",
      createdAt: DateTime(2025, 12, 20),
    ),
    PTSession(
      id: 10,
      ptContranstId: 1001,
      sessionDate: DateTime(2026, 1, 19),
      startTime: DateTime(2026, 1, 19, 18, 0),
      endTime: DateTime(2026, 1, 19, 19, 0),
      notes: "Final assessment",
      createdAt: DateTime(2025, 12, 20),
    ),
  ];

  _changePage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 85,
                decoration: BoxDecoration(color: AppColors.aquaTeal),
                child: Center(
                  child: Text(
                    "All Appointment",
                    style: TextStyle(
                      color: AppColors.light,
                      fontSize: AppSizes.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: pageIndex == 0
                        ? MaterialStateProperty.all(AppColors.aquaTeal)
                        : MaterialStateProperty.all(AppColors.light),
                  ),
                  onPressed: () => _changePage(0),
                  child: Text("Complete", style: TextStyle(color:pageIndex == 0? AppColors.light:AppColors.black),),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: pageIndex == 1
                        ? MaterialStateProperty.all(AppColors.aquaTeal)
                        : MaterialStateProperty.all(AppColors.light),
                  ),
                  onPressed: () => _changePage(1),
                  child: Text("Upcoming", style: TextStyle(color:pageIndex == 1? AppColors.light:AppColors.black)),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: pageIndex == 2
                        ? MaterialStateProperty.all(AppColors.aquaTeal)
                        : MaterialStateProperty.all(AppColors.light),
                  ),
                  onPressed: () => _changePage(2),
                  child: Text("Cancelled", style: TextStyle(color:pageIndex == 2? AppColors.light:AppColors.black)),
                ),
              ],
            ),
          ),

          Expanded(
            child: <Widget>[
              CompeteSess(sessions: sessions),
              UpcomingPage(pts: sessions),
              CancelPage(sessions: sessions),
            ][pageIndex],
          ),
        ],
      ),
    );
  }
}

class CompeteSess extends StatelessWidget {
  const CompeteSess({super.key, required this.sessions});

  final List<PTSession> sessions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Divider(),
              Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PT. Dinh Hieu",
                          style: TextStyle(
                            color: AppColors.aquaTeal,
                            fontSize: AppSizes.small,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("IFBBQ"),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 15),
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.alarm, color: AppColors.aquaTeal),
                              Text(
                                "${DateFormat("EEE  dd/MM/yyyy").format(sessions[index].startTime)}  ${DateFormat("hh:mm").format(sessions[index].startTime)} - ${DateFormat("hh:mm").format(sessions[index].endTime)}",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 35,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: BoxBorder.all(color: AppColors.aquaTeal),
                          ),
                          child: Center(
                            child: Text(
                              "ReBook",
                              style: TextStyle(
                                fontSize: AppSizes.small,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>ReviewPage())),
                          child: Container(
                            height: 35,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: BoxBorder.all(color: AppColors.aquaTeal),
                            ),
                            child: Center(
                              child: Text(
                                "Review",
                                style: TextStyle(
                                  fontSize: AppSizes.small,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CancelPage extends StatelessWidget {
  const CancelPage({super.key, required this.sessions});

  final List<PTSession> sessions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Divider(),
              Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PT. Dinh Hieu",
                          style: TextStyle(
                            color: AppColors.aquaTeal,
                            fontSize: AppSizes.small,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("IFBBQ"),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 15),
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.alarm, color: AppColors.aquaTeal),
                              Text(
                                "${DateFormat("EEE  dd/MM/yyyy").format(sessions[index].startTime)}  ${DateFormat("hh:mm").format(sessions[index].startTime)} - ${DateFormat("hh:mm").format(sessions[index].endTime)}",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>ReviewPage())),
                        child: Container(
                          height: 35,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: BoxBorder.all(color: AppColors.aquaTeal,width: 2),
                          ),
                          child: Center(
                            child: Text(
                              "Add Review",
                              style: TextStyle(
                                fontSize: AppSizes.small,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class UpcomingPage extends StatelessWidget {
  const UpcomingPage({super.key, required this.pts});

  final List<PTSession> pts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: pts.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Divider(),
              Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PT. Dinh Hieu",
                          style: TextStyle(
                            color: AppColors.aquaTeal,
                            fontSize: AppSizes.small,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("IFBBQ"),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: BoxBorder.all(color: AppColors.aquaTeal),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.date_range, color: AppColors.aquaTeal),
                              Text(
                                DateFormat(
                                  "EEE  dd/MM/yyyy",
                                ).format(pts[index].startTime),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: BoxBorder.all(color: AppColors.aquaTeal),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.alarm, color: AppColors.aquaTeal),
                              Text(
                                "  ${DateFormat("hh:mm").format(pts[index].startTime)} - ${DateFormat("hh:mm").format(pts[index].endTime)}",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>YourSessionPage()))
                          },
                          child: Container(
                            height: 35,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: BoxBorder.all(color: AppColors.aquaTeal),
                            ),
                            child: Center(
                              child: Text(
                                "Details",
                                style: TextStyle(
                                  fontSize: AppSizes.small,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            
                          },
                          icon: Icon(Icons.check, color: AppColors.aquaTeal),
                        ),
                        IconButton(
                          onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context)=> CancelAppoint()));},
                          icon: Icon(Icons.cancel, color: AppColors.aquaTeal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
