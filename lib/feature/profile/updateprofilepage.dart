import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';

class ProfileUpdatePage extends StatelessWidget {
  const ProfileUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 65,
                      child: Text("Profile"),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.settings),
                        ),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundImage: AssetImage(
                    "assets/PXL_20251014_011048644~2.jpg",
                  ),
                  radius: 62,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Full Name"),
              TextField(),
              Text("Phone Number"),
              TextField(),
              Text("Email"),
              TextField(),
              Text("Date of Birth"),
              TextField(),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.aquaTeal),
                      child: Text("Update Profile"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}