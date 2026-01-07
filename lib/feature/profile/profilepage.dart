import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.aquaTeal),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 70,
                      child: Center(
                        child: Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: AppSizes.small,
                            fontWeight: FontWeight.bold,
                            color: AppColors.light,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.light,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          "assets/PXL_20251014_011048644~2.jpg",
                        ),
                        radius: 62,
                      ),
                      Column(
                        children: [
                          Text(
                            "Jane Doe",
                            style: TextStyle(
                              color: AppColors.light,
                              fontSize: AppSizes.small,
                            ),
                          ),
                          Text(
                            "+84 08xx xxx xxx",
                            style: TextStyle(color: AppColors.light),
                          ),
                          Text(
                            "janedone@gmail.com",
                            style: TextStyle(color: AppColors.light),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: AppColors.light),
                      Text(
                        "Profile",
                        style: TextStyle(fontSize: AppSizes.small),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: AppColors.aquaTeal),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: AppColors.light),
                      Text(
                        "Favorite",
                        style: TextStyle(fontSize: AppSizes.small),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: AppColors.aquaTeal),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: AppColors.light),
                      Text(
                        "Payment",
                        style: TextStyle(fontSize: AppSizes.small),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: AppColors.aquaTeal),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.privacy_tip_rounded, color: AppColors.light),
                      Text(
                        "private",
                        style: TextStyle(fontSize: AppSizes.small),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: AppColors.aquaTeal),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: AppColors.light),
                      Text(
                        "Setting",
                        style: TextStyle(fontSize: AppSizes.small),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: AppColors.aquaTeal),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.question_mark, color: AppColors.light),
                      Text("Help", style: TextStyle(fontSize: AppSizes.small)),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: AppColors.aquaTeal),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.light),
                      Text(
                        "Log Out",
                        style: TextStyle(fontSize: AppSizes.small),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
