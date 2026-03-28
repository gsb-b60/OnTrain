import 'package:flutter/material.dart';
import 'package:ontrain/UI/headerBar.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/feature/auth/signUpScreen.dart';
import 'package:ontrain/feature/book/home.dart';
import 'package:ontrain/feature/book/home/homepage.dart';
import 'package:ontrain/feature/auth/welcomeScreeen.dart';
import 'package:ontrain/main.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isHidden = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    try {
      context.read<Authcontrolller>().signIn(email, password);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.toString()}')),
      );
    }
    print("tring to sign in with email: $email and password: $password");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderBar(title: "Sign In"),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: AppSizes.large,
                      fontWeight: FontWeight.bold,
                      color: AppColors.aquaTeal,
                      height: 3,
                    ),
                    textAlign: TextAlign.left,
                  ),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your email',
                      fillColor: AppColors.greyAqua,
                      hintStyle: TextStyle(color: AppColors.aquaTeal),
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: passwordController,
                    obscureText: isHidden,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your password',
                      fillColor: AppColors.greyAqua,
                      hintStyle: TextStyle(color: AppColors.aquaTeal),
                      filled: true,
                      suffixIcon: GestureDetector(
                        onTapDown: (_) {
                          setState(() {
                            isHidden = false; // show while holding
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            isHidden = true; // hide when release
                          });
                        },
                        onTapCancel: () {
                          setState(() {
                            isHidden = true; // also hide if gesture cancelled
                          });
                        },
                        child: Icon(Icons.visibility),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => {
                          signIn(),
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => HomeScaff(),
                          //   ),
                          // ),
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 30.0,
                            horizontal: 30,
                          ),
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppGradients.focus,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: AppSizes.medium,
                                fontWeight: FontWeight.bold,
                                color: AppColors.light,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: AppColors.black),
                                children: [
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(
                                      color: AppColors.aquaTeal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupScreen(),
                                ),
                              ),
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
