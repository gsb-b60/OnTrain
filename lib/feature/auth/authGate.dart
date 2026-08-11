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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session == null) {
          return SignInScreen();
        } else {
          return HomePage();
        }
      },
    );
  }
}
