import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ontrain/feature/auth/signIn.dart';
import 'package:ontrain/feature/book/home/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGateWay extends StatelessWidget {
  const AuthGateWay({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        print("======== AUTH CHANGE ========");
        print("State: ${snapshot.connectionState}");
        print("HasData: ${snapshot.hasData}");
        print("Raw event: ${snapshot.data}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final session = snapshot.hasData ? snapshot.data!.session : null;

        print("Session: $session");
        print("User: ${session?.user?.email}");
        if (session == null) {
          print("➡️ Go to SignInScreen");
          return SignInScreen();
        } else {
          print("➡️ Go to HomePage");
          return HomePage();
        }
      },
    );
  }
}
