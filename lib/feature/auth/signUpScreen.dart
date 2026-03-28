import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/UI/headerBar.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/enum/userRole.dart';
import 'package:ontrain/feature/auth/signIn.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  DateTime selectedDate = DateTime.now();
  UserRole? selectedRole;

  final passwordControlller = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController(); 
  void signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordControlller.text.trim();

    print("--- Registration Data ---");
    print("User: ${name} (${selectedRole?.displayName})");
    print("Email: ${email}");
    print("Email: ${password}");
    print(
      "DOB: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
    );

    if (name.isEmpty || email.isEmpty || password.isEmpty || selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select a role')),
      );
      return;
    }

    try {
      context.read<Authcontrolller>().signUp(email, password, selectedRole!, name);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    }
  }

  void showCupertinoDatePicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          height: 300,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    backgroundColor: AppColors.gray100,
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        selectedDate = newDate;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderBar(title: "Sign up"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter your name",
                      style: TextStyle(
                        fontSize: AppSizes.small,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        height: 2.5,
                      ),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        fillColor: AppColors.greyAqua,
                        filled: true,

                        contentPadding: EdgeInsets.all(7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'your name',
                        hintStyle: TextStyle(color: AppColors.aquaTeal),
                      ),
                    ),
                    Text(
                      "Password",
                      style: TextStyle(
                        fontSize: AppSizes.small,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        height: 2.5,
                      ),
                    ),
                    TextField(
                      obscureText: true,
                      controller: passwordControlller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter your password',
                        fillColor: AppColors.greyAqua,
                        hintStyle: TextStyle(color: AppColors.aquaTeal),
                        filled: true,
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
                      controller: emailController,
                      decoration: InputDecoration(
                        fillColor: AppColors.greyAqua,
                        filled: true,

                        contentPadding: EdgeInsets.all(7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'your email',
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
                        showCupertinoDatePicker();
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
                            DateFormat(
                              'dd MM yyyy',
                            ).format(selectedDate).toString().substring(0, 10),
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
                        DropdownButton<UserRole>(
                          value: selectedRole,
                          hint: Text("Select role"),
                          items: UserRole.values.map((UserRole role) {
                            return DropdownMenuItem<UserRole>(
                              value: role,
                              child: Text(role.displayName),
                            );
                          }).toList(),
                          onChanged: (UserRole? newValue) {
                            setState(() {
                              selectedRole = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Column(
                      children: [
                        // Text("By continuing, you agree to"),
                        // Text.rich(
                        //   TextSpan(
                        //     text: "Terms of Use",
                        //     style: TextStyle(color: AppColors.aquaTeal),
                        //     children: [
                        //       TextSpan(
                        //         text: " and ",
                        //         style: TextStyle(color: AppColors.black),
                        //       ),
                        //       TextSpan(
                        //         text: "Privacy Policy",
                        //         style: TextStyle(color: AppColors.aquaTeal),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        GestureDetector(
                          onTap: () => {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => HomeScaff(),
                            //   ),
                            // ),
                            signUp(),
                          },

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
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     IconButton(
                        //       onPressed: () {},
                        //       icon: Icon(
                        //         Icons.facebook,
                        //         size: 40,
                        //         color: AppColors.aquaTeal,
                        //       ),
                        //     ),
                        //     IconButton(
                        //       onPressed: () {},
                        //       icon: Icon(
                        //         Icons.g_mobiledata,
                        //         size: 40,
                        //         color: AppColors.aquaTeal,
                        //       ),
                        //     ),
                        //   ],
                        // ),
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
                                        builder: (context) => SignInScreen(),
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
