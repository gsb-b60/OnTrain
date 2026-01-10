import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/feature/profile/updateprofilepage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
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
                            fontSize: AppSizes.medium,
                            fontWeight: FontWeight.bold,
                            color: AppColors.light,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 350,
                  height: 100,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                                icon: Icon(Icons.edit_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Jane Doe",
                            style: TextStyle(
                              color: AppColors.light,
                              fontSize: AppSizes.small,
                              fontWeight: FontWeight.bold,
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                SettingButton(ico: Icons.person, title: "Profile",onCall: () => {Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileUpdatePage())) },),
                SettingButton(ico: Icons.favorite, title: "Favorite",onCall: () => {},),
                SettingButton(ico: Icons.payment, title: "Payment",onCall: () => {},),
                SettingButton(ico: Icons.privacy_tip, title: "Private", onCall: ()=>{}),
                SettingButton(ico: Icons.settings, title: "Settings", onCall: ()=>{}),
                SettingButton(ico: Icons.question_mark, title: "Helps", onCall: ()=>{}),
                SettingButton(ico: Icons.logout, title: "Log Out", onCall: ()=>{}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingButton extends StatelessWidget {
  IconData ico;
  String title;
  VoidCallback onCall;
  SettingButton({
    super.key,
    required this.ico,
    required this.title,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCall,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: 45,
              width: 75,
              decoration: BoxDecoration(
                color: AppColors.aquaTeal,
                shape: BoxShape.circle
              ),
              child: Icon(ico, color: AppColors.light),
            ),
            Text(
              title,
              style: TextStyle(fontSize: AppSizes.small),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: AppColors.aquaTeal),
          ],
        ),
      ),
    );
  }
}
