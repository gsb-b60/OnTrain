import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.brand),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(height: 280, "assets/fitness-app-52.png"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ON",
                  style: TextStyle(
                    fontSize: AppSizes.large,
                    fontWeight: FontWeight.bold,
                    color: AppColors.light,
                  ),
                ),
                Text(
                  "Train",
                  style: TextStyle(
                    fontSize: AppSizes.large,
                    fontWeight: FontWeight.w400,
                    color: AppColors.light,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
