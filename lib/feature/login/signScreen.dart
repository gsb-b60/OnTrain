import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/feature/book/home.dart';
import 'package:ontrain/feature/book/homepage.dart';
import 'package:ontrain/feature/login/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  DateTime selectedDate = DateTime.now();
  String type = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Stack(
      //     children: [
      //       Center(
      //         child: Text(
      //           "Sign Up",
      //           style: TextStyle(
      //             fontSize: AppSizes.medium,
      //             fontWeight: FontWeight.bold,
      //             color: AppColors.light,
      //           ),
      //           textAlign: TextAlign.center,
      //         ),
      //       ),
      //       Align(
      //         alignment: Alignment.centerLeft,
      //         child: IconButton(
      //           onPressed: () {},
      //           icon: Icon(Icons.arrow_back_ios_sharp, color: AppColors.light),
      //         ),
      //       ),
      //     ],
      //   ),

      //   backgroundColor: AppColors.aquaTeal,
      // ),
      body: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(gradient: AppGradients.brand),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    "Sign Up",
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Full Name",
                      style: TextStyle(
                        fontSize: AppSizes.small,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        height: 2.5,
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        fillColor: AppColors.greyAqua,
                        filled: true,

                        contentPadding: EdgeInsets.all(7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Enter your full name',
                        hintStyle: TextStyle(color: AppColors.aquaTeal),
                      ),
                    ),
                    Text(
                      "Pass word",
                      style: TextStyle(
                        fontSize: AppSizes.small,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        height: 2.5,
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        fillColor: AppColors.greyAqua,
                        filled: true,

                        contentPadding: EdgeInsets.all(7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: '************',
                        hintStyle: TextStyle(color: AppColors.aquaTeal),
                      ),
                    ),
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: AppSizes.small,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        height: 2.5,
                      ),
                    ),

                    TextField(
                      decoration: InputDecoration(
                        fillColor: AppColors.greyAqua,
                        filled: true,

                        contentPadding: EdgeInsets.all(7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'example@example.com',
                        hintStyle: TextStyle(color: AppColors.aquaTeal),
                      ),
                    ),
                    Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: AppSizes.small,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        height: 2.5,
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        fillColor: AppColors.greyAqua,
                        filled: true,

                        contentPadding: EdgeInsets.all(7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: '8xxxxxxxxx',
                        hintStyle: TextStyle(color: AppColors.aquaTeal),
                      ),
                    ),
                    Text(
                      "Date of Birth",
                      style: TextStyle(
                        fontSize: AppSizes.small,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        height: 2.5,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        showCupertinoModalPopup<void>(
                          context: context,
                          builder: (BuildContext context) => SizedBox(
                            height: 250,
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: selectedDate,
                              onDateTimeChanged: (DateTime newDate) {
                                setState(() {
                                  selectedDate = newDate;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: AppColors.greyAqua,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            selectedDate.toString().substring(0, 10),
                            style: TextStyle(color: AppColors.aquaTeal),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Account Type",
                          style: TextStyle(
                            fontSize: AppSizes.small,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                            height: 2.5,
                          ),
                        ),
                        SizedBox(width: 20),
                        DropdownButton<String>(
                          items: <String>['User', 'Trainer'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              type = newValue!;
                            });
                          },
                          value: type.isEmpty ? null : type,
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Column(
                      children: [
                        Text("By continuing, you agree to"),
                        Text.rich(
                          TextSpan(
                            text: "Terms of Use",
                            style: TextStyle(color: AppColors.aquaTeal),
                            children: [
                              TextSpan(
                                text: " and ",
                                style: TextStyle(color: AppColors.black),
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(color: AppColors.aquaTeal),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScaff(),
                            ),
                          ),

                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppGradients.focus,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            height: 50,
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                              horizontal: 55,
                              vertical: 20,
                            ),
                            child: Center(
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: AppSizes.medium,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.light,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text("or sign up with"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.facebook,
                                size: 40,
                                color: AppColors.aquaTeal,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.g_mobiledata,
                                size: 40,
                                color: AppColors.aquaTeal,
                              ),
                            ),
                          ],
                        ),
                        Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: AppColors.black),
                            children: [
                              TextSpan(
                                text: "Log In",
                                style: TextStyle(
                                  color: AppColors.aquaTeal,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LogInScreen(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
