import 'package:flutter/material.dart';
import 'package:ontrain/UI/headerBar.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/feature/auth/signUpScreen.dart';
import 'package:ontrain/model/stateEnum.dart';
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
    final authController = context.read<AuthController>();
    final result = await authController.signIn(
      emailController.text,
      passwordController.text,
    );
    if (!mounted) {
      return;
    }

    if (result.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.error ?? result.error?.message ?? 'Sign in failed',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đăng nhập thành công!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderBar(title: "Sign In", enableBackButton: false),
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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 15,
                            decoration: BoxDecoration(
                              color: AppColors.aquaTeal,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'EMAIL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppColors.aquaTeal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: AppColors.aquaTeal),
                          fillColor: AppColors.greyAqua,
                          filled: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 15,
                            decoration: BoxDecoration(
                              color: AppColors.aquaTeal,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppColors.aquaTeal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                                isHidden = false;
                              });
                            },
                            onTapUp: (_) {
                              setState(() {
                                isHidden = true;
                              });
                            },
                            onTapCancel: () {
                              setState(() {
                                isHidden = true;
                              });
                            },
                            child: Icon(Icons.visibility),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Container(
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
                        child: ElevatedButton(
                          onPressed: () {
                            if (auth.state != ViewState.loading) {
                              signIn();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: auth.state == ViewState.loading
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.light,
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    key: const ValueKey('signin'),
                                    style: TextStyle(
                                      fontSize: AppSizes.medium,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.light,
                                    ),
                                  ),
                          ),
                        ),
                      ),
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
