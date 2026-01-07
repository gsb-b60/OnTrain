import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';

class YourSessionPage extends StatelessWidget {
  const YourSessionPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.aquaTeal),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 65,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              "Your Session",
                              style: TextStyle(
                                color: AppColors.light,
                                fontSize: AppSizes.small,
                                fontWeight: FontWeight.bold,
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
                      padding: EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.light,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(
                              "assets/PXL_20251014_011048644~2.jpg",
                            ),
                            radius: 42,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Dr. Emma Hall",
                                  style: TextStyle(
                                    color: AppColors.aquaTeal,
                                    fontSize: AppSizes.small,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("IFBBQ"),
                                Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(8),
                                      width: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: BoxBorder.all(
                                          color: Colors.grey,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                            color: AppColors.aquaTeal,
                                          ),
                                          Text("5"),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: BoxBorder.all(
                                          color: Colors.grey,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                            Icons.comment,
                                            size: 16,
                                            color: AppColors.aquaTeal,
                                          ),
                                          Text("40"),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: AppColors.greyAqua,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.question_mark,
                                          size: 18,
                                          color: AppColors.aquaTeal,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: AppColors.greyAqua,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.favorite,
                                          size: 18,
                                          color: AppColors.aquaTeal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Divider(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 140,
                              decoration: BoxDecoration(
                                color: AppColors.aquaTeal,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Text(
                                DateFormat("dd/MM/yyyy").format(DateTime.now()),
                                style: TextStyle(
                                  color: AppColors.light,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.check_circle_rounded,
                                size: 32,
                                color: AppColors.aquaTeal,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.cancel_rounded,
                                size: 32,
                                color: AppColors.aquaTeal,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            DateFormat("EEE hh:mm").format(DateTime.now()),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Column(
                        children: [
                          Divider(),
                          Row(
                            children: [
                              Text("Booking for"),
                              Spacer(),
                              Text(
                                "another person",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.small,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Full Name"),
                              Spacer(),
                              Text(
                                "Jane Doe",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.small,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Age"),
                              Spacer(),
                              Text(
                                "30",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.small,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Gender"),
                              Spacer(),
                              Text(
                                "Female",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.small,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                        ],
                      ),
                    ),
    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          width: double.infinity,
                          child: Text("Problem"),
                        ),
                        Text("problem for something"),
                      ],
                    ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
          Positioned.fill(
            bottom: 50,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: Container(
                      height: 38,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: BoxBorder.all(
                          color: AppColors.aquaTeal,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Payment",
                          style: TextStyle(
                            color: AppColors.aquaTeal,
                            fontSize: AppSizes.small,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      height: 38,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.aquaTeal,
                      ),
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: AppColors.light,
                            fontSize: AppSizes.small,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}