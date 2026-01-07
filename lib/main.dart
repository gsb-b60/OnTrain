import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/feature/book/cancelsess.dart';

import 'package:ontrain/feature/login/register_screen.dart';

import 'package:ontrain/feature/login/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.aquaTeal,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
      home: Scaffold(body: Center(child: Text("hello world"))),
    );
  }
}

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 65,
            width: double.infinity,
            child: Stack(
              children: [
                Center(child: Text("Review ")),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_back_ios),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text("Review"),
          CircleAvatar(
            backgroundImage: AssetImage("assets/PXL_20251014_011048644~2.jpg"),
            radius: 65,
          ),
          Text(
            "Dinh Hieu",
            style: TextStyle(
              color: AppColors.aquaTeal,
              fontSize: AppSizes.small,
            ),
          ),
          Text("IFBBQ"),
          Row(
            children: [
              IconButton.outlined(onPressed: () {}, icon: Icon(Icons.favorite)),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: BoxBorder.all(color: AppColors.aquaTeal),
                ),
                child: Row(
                  children: [
                    Icon(Icons.start),
                    Icon(Icons.start),
                    Icon(Icons.start),
                    Icon(Icons.start),
                    Icon(Icons.start),
                  ],
                ),
              ),
            ],
          ),
          TextField(),
          GestureDetector(
            onTap: () {},
            child: Container(child: Text("Add Review ")),
          ),
        ],
      ),
    );
  }
}

class SessionInfor extends StatefulWidget {
  const SessionInfor({super.key});

  @override
  State<SessionInfor> createState() => _SessionInforState();
}

class _SessionInforState extends State<SessionInfor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class CancelPage extends StatelessWidget {
  const CancelPage({super.key, required this.pts});

  final List<PT> pts;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Column(
            children: [
              Divider(),
              Column(
                children: [Text(pts[index].name), Text(pts[index].address)],
              ),
              ElevatedButton(onPressed: () {}, child: Text("Add Review")),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}

class UpcomingPage extends StatelessWidget {
  const UpcomingPage({super.key, required this.pts});

  final List<PT> pts;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Column(
            children: [
              Divider(),
              Column(
                children: [Text(pts[index].name), Text(pts[index].address)],
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      DateFormat(
                        "EEE  dd/MM/yyyy",
                      ).format(pts[index].createdAt),
                    ),
                  ),
                  ElevatedButton(onPressed: () {}, child: Text("Add Review")),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: Text("Child")),
                  IconButton(onPressed: () {}, icon: Icon(Icons.check)),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.indeterminate_check_box_sharp),
                  ),
                ],
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}

// TableCalendar(
//               firstDay: DateTime.utc(2010, 10, 16),
//               lastDay: DateTime.utc(2030, 3, 14),
//               focusedDay: DateTime.now(),
//             ),

class StartSplash extends StatefulWidget {
  const StartSplash({super.key});

  @override
  State<StartSplash> createState() => _StartSplashState();
}

class _StartSplashState extends State<StartSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}
