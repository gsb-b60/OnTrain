import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/feature/login/login_screen.dart';
import 'package:ontrain/feature/login/signScreen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset(
              "assets/fitness-app-main.png",
              height: AppSizes.imageHeight.toDouble(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "On",
                  style: TextStyle(
                    fontSize: AppSizes.large,
                    fontWeight: FontWeight.bold,
                    color: AppColors.aquaTeal,
                  ),
                ),
                Text(
                  "Train",
                  style: TextStyle(
                    fontSize: AppSizes.large,
                    fontWeight: FontWeight.w400,
                    color: AppColors.aquaTeal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 100),
            Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogInScreen()),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    height: 50,
                    width: 200,
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
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: AppColors.greyAqua,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: AppSizes.medium,
                          fontWeight: FontWeight.bold,
                          color: AppColors.aquaTeal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 75),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
