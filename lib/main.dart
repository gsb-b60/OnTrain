import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/feature/auth/authGate.dart';
import 'package:ontrain/feature/book/booking.dart';
import 'package:ontrain/feature/auth/welcomeScreeen.dart';
import 'package:ontrain/feature/auth/splashScreen.dart';
import 'package:ontrain/repo/auth/authRepo.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localization/flutter_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ctihmfzqfohihmsngcjl.supabase.co',
    anonKey: 'sb_publishable_US5Qyssn7nDAUelzuMyKkQ_JyVQ5MCO',
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<Authrepo>(
          create: (_)=> Authrepo(),
        ),
        ChangeNotifierProvider<Authcontrolller>(
          create: (context) => Authcontrolller(context.read<Authrepo>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale('en')],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.aquaTeal,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
      home: AuthGateWay(),
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
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}
