import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/bookingController.dart';
import 'package:ontrain/controller/calendarController.dart';
import 'package:ontrain/controller/notificationController.dart';
import 'package:ontrain/controller/paymentController.dart';
import 'package:ontrain/controller/ptController.dart';
import 'package:ontrain/controller/ptEarningsController.dart';
import 'package:ontrain/controller/reviewController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/feature/auth/authGate.dart';
import 'package:ontrain/feature/book/bookingScreen.dart';
import 'package:ontrain/feature/auth/welcomeScreeen.dart';
import 'package:ontrain/feature/auth/splashScreen.dart';
import 'package:ontrain/repo/auth/authRepo.dart';
import 'package:ontrain/repo/bookingRepository.dart';
import 'package:ontrain/repo/earningsRepository.dart';
import 'package:ontrain/repo/notificationRepository.dart';
import 'package:ontrain/repo/paymentRepository.dart';
import 'package:ontrain/repo/payoutRepository.dart';
import 'package:ontrain/repo/ptRepository.dart';
import 'package:ontrain/repo/reviewRepository.dart';
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
        // repositories
        Provider<Authrepo>(create: (_) => Authrepo(supabaseClient: Supabase.instance.client)),

        Provider<Ptrepository>(create: (_) => Ptrepository(supabaseClient: Supabase.instance.client)),

        Provider<BookingRepository>(create: (_) => BookingRepository(supabaseClient: Supabase.instance.client)),

        Provider<PaymentRepository>(create: (_) => PaymentRepository(supabaseClient: Supabase.instance.client)),

        Provider<EarningsRepository>(create: (_) => EarningsRepository(supabaseClient: Supabase.instance.client)),

        Provider<PayoutRepository>(create: (_) => PayoutRepository(supabaseClient: Supabase.instance.client)),

        Provider<NotificationRepository>(create: (_) => NotificationRepository(supabaseClient: Supabase.instance.client)),

        Provider<ReviewRepository>(create: (_) => ReviewRepository(supabaseClient: Supabase.instance.client)),

        // base controllers
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(repo: context.read<Authrepo>()),
        ),

        ChangeNotifierProvider<Calendarcontroller>(
          create: (_) => Calendarcontroller(),
        ),

        // depends on:
        // PaymentRepository
        // AuthController
        ChangeNotifierProvider<Paymentcontroller>(
          create: (context) => Paymentcontroller(
            repository: context.read<PaymentRepository>(),
            authController: context.read<AuthController>(),
          ),
        ),

        // depends on:
        // BookingRepository
        // AuthController
        // Calendarcontroller
        // PaymentController
        ChangeNotifierProvider<Bookingcontroller>(
          create: (context) => Bookingcontroller(
            repository: context.read<BookingRepository>(),
            authController: context.read<AuthController>(),
            calendarController: context.read<Calendarcontroller>(),
            paymentController: context.read<Paymentcontroller>(),
          ),
        ),

        // depends on:
        // EarningsRepository
        // PayoutRepository
        // AuthController
        ChangeNotifierProvider<PTEarningsController>(
          create: (context) => PTEarningsController(
            earningsRepository: context.read<EarningsRepository>(),
            payoutRepository: context.read<PayoutRepository>(),
            authController: context.read<AuthController>(),
          ),
        ),

        // depends on:
        // NotificationRepository
        // AuthController
        ChangeNotifierProvider<NotificationController>(
          create: (context) => NotificationController(
            repository: context.read<NotificationRepository>(),
            authController: context.read<AuthController>(),
          ),
        ),

        // depends on:
        // ReviewRepository
        // AuthController
        ChangeNotifierProvider<ReviewController>(
          create: (context) => ReviewController(
            repository: context.read<ReviewRepository>(),
            authController: context.read<AuthController>(),
          ),
        ),

        // depends on:
        // Ptrepository
        // AuthController
        // Bookingcontroller
        ChangeNotifierProvider<PTController>(
          create: (context) => PTController(
            repo: context.read<Ptrepository>(),
            authController: context.read<AuthController>(),
            bookingController: context.read<Bookingcontroller>(),
          )..initController(),
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
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
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