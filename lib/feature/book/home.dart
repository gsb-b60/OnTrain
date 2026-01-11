import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/feature/book/homepage.dart';
import 'package:ontrain/feature/book/sessionpage.dart';
import 'package:ontrain/feature/profile/profilepage.dart';

class HomeScaff extends StatefulWidget {
  const HomeScaff({super.key});

  @override
  State<HomeScaff> createState() => _HomeScaffState();
}

class _HomeScaffState extends State<HomeScaff> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        backgroundColor: AppColors.greyAqua,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentPageIndex,
        selectedItemColor: AppColors.aquaTeal,
        selectedIconTheme: const IconThemeData(
          color: AppColors.aquaTeal,
          size: 28,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Colors.blueGrey,
          size: 22,
        ),

        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),

          //BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
      body: <Widget>[
        HomePage(),
        SessionPage(),
        ProfilePage(),
      ][currentPageIndex],
    );
  }
}
