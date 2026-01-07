import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/feature/login/register_screen.dart';
import 'package:ontrain/main.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(gradient: AppGradients.brand),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: AppSizes.medium,
                      fontWeight: FontWeight.bold,
                      color: AppColors.light,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.light),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
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
                Row(),
                Text(
                  "Email or Mobile Number",
                  style: TextStyle(
                    fontSize: AppSizes.small,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    height: 3,
                  ),
                  textAlign: TextAlign.left,
                ),
                TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your email or mobile number',
                    fillColor: AppColors.greyAqua,
                    hintStyle: TextStyle(color: AppColors.aquaTeal),
                    filled: true,
                  ),
                ),
                Text(
                  "Password",
                  style: TextStyle(
                    fontSize: AppSizes.small,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                    height: 3,
                  ),
                  textAlign: TextAlign.left,
                ),
                TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '*********',
                    fillColor: AppColors.greyAqua,
                    hintStyle: TextStyle(color: AppColors.aquaTeal),
                    filled: true,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppColors.aquaTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
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

                    Text("or"),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.fingerprint_outlined,
                        size: 40,
                        color: AppColors.aquaTeal,
                      ),
                    ),
                    SizedBox(height: 20),
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          ),
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
    );
  }
}