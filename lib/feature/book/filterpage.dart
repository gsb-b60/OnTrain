import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';

class Filterpage extends StatefulWidget {
  const Filterpage({super.key});

  @override
  State<Filterpage> createState() => _FilterpageState();
}

class _FilterpageState extends State<Filterpage> {
  bool isSwitchOn = false;
  bool isMale = false;
  bool isFemale = false;
  bool isFresher = false;
  bool isSenior = false;
  bool isJunior = false;
  double age = 0.3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.aquaTeal),
            height: 65,
            width: double.infinity,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    "Filters",
                    style: TextStyle(
                      color: AppColors.light,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.medium,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios, color: AppColors.light),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      child: Text(
                        "reset",
                        style: TextStyle(
                          color: AppColors.aquaTeal,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.aquaTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Available today"),
                    Switch(
                      value: isSwitchOn,
                      onChanged: (bool input) {
                        setState(() {
                          isSwitchOn = input;
                        });
                      },
                    ),
                  ],
                ),
                Divider(),
                Text("Gender"),
                Row(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isMale,
                          onChanged: (bool? input) {
                            setState(() {
                              isMale = input!;
                            });
                          },
                        ),
                        Text("Male"),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isFemale,
                          onChanged: (bool? input) {
                            setState(() {
                              isFemale = input!;
                            });
                          },
                        ),
                        Text("Female"),
                      ],
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: [
                    Text(
                      "Top Rated",
                      style: TextStyle(
                        color: AppColors.aquaTeal,
                        fontSize: AppSizes.small,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.star),
                          Icon(Icons.star),
                          Icon(Icons.star),
                          Icon(Icons.star),
                          Icon(Icons.star_border),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 20),
                Text(
                  "Work Experience (Years)",
                  style: TextStyle(
                    color: AppColors.aquaTeal,
                    fontSize: AppSizes.small,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BtnEp(
                        title: "1-5",
                        onCall: () => {
                          setState(() {
                            isFresher = !isFresher;
                          }),
                        },
                        isSelected: isFresher,
                      ),
                      BtnEp(
                        title: "6-9",
                        onCall: () => {
                          setState(() {
                            isJunior = !isJunior;
                          }),
                        },
                        isSelected: isJunior,
                      ),
                      BtnEp(
                        title: "10>",
                        onCall: () => {
                          setState(() {
                            isSenior = !isSenior;
                          }),
                        },
                        isSelected: isSenior,
                      ),
                    ],
                  ),
                ),
                Divider(),
                // Container(
                //   height: 120,
                //   width: double.infinity,
                //   child: SingleChildScrollView(
                //     scrollDirection: Axis.horizontal,
                //     child: Row(
                //       children: [
                //         Container(
                //           height: 80,
                //           width: 80,
                //           decoration: BoxDecoration(
                //             color: AppColors.aquaTeal,
                //             borderRadius: BorderRadius.circular(16),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // Divider(),
                Text("Age", style: TextStyle(color: AppColors.aquaTeal)),
                Slider(
                  min: 0.2,
                  max: 0.8,
                  divisions: 80,
                  value: age,
                  label: "${(age * 100).floor()}",
                  onChanged: (double a) {
                    setState(() {
                      age = a;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text("20"), Text("40"), Text("60"), Text("80")],
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

class BtnEp extends StatelessWidget {
  BtnEp({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onCall,
  });
  String title;
  bool isSelected;
  VoidCallback onCall;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCall,
      child: Container(
        width: 70,
        height: 30,
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: BoxBorder.all(color: AppColors.aquaTeal),
          color: isSelected ? AppColors.aquaTeal : AppColors.light,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.light : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
