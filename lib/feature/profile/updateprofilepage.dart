import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';

class ProfileUpdatePage extends StatelessWidget {
  const ProfileUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(color: AppColors.aquaTeal),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 65,
                      child: Center(
                        child: Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: AppSizes.medium,
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.light,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.settings, color: AppColors.light),
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                        "assets/PXL_20251014_011048644~2.jpg",
                      ),
                      radius: 62,
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton.filled(
                          onPressed: () {},
                          icon: Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Full Name",
                  style: TextStyle(
                    fontSize: AppSizes.small,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextOutput(),
                Text(
                  "Phone Number",
                  style: TextStyle(
                    fontSize: AppSizes.small,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextOutput(),
                Text(
                  "Email",
                  style: TextStyle(
                    fontSize: AppSizes.small,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextOutput(),
                Text(
                  "Date of Birth",
                  style: TextStyle(
                    fontSize: AppSizes.small,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextOutput(),
                Container(

                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.aquaTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Center(
                    child: Text(
                      "Cancel Appointment",
                      style: TextStyle(
                        color: AppColors.light,
                        fontWeight: FontWeight.w500,
                        fontSize: AppSizes.small,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TextOutput extends StatelessWidget {
  const TextOutput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        maxLines: 1,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.greyAqua,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
