import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/feature/book/booking.dart';
import 'package:ontrain/feature/book/home.dart';
import 'package:ontrain/feature/book/homepage.dart';
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
   // routes: ,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.aquaTeal,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
      home:Booking(),
    );
  }
}



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
