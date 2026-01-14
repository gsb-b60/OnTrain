import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/feature/book/booking.dart';

class PTCVPage extends StatelessWidget {
  const PTCVPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 40),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(gradient: AppGradients.brand),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: AppColors.light,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.greyAqua,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: AppColors.aquaTeal,
                                  ),
                                  Text(
                                    "Schedule",
                                    style: TextStyle(color: AppColors.aquaTeal),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filled(
                              color: AppColors.aquaTeal,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.greyAqua,
                              ),
                              iconSize: 16,
                              visualDensity: VisualDensity.compact,
                              onPressed: () {},
                              icon: Icon(Icons.call),
                            ),
                            IconButton.filled(
                              color: AppColors.aquaTeal,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.greyAqua,
                              ),
                              iconSize: 16,
                              visualDensity: VisualDensity.compact,
                              onPressed: () {},
                              icon: Icon(Icons.chat),
                            ),
                            Spacer(),
                            IconButton.filled(
                              color: AppColors.aquaTeal,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.greyAqua,
                              ),
                              iconSize: 16,
                              visualDensity: VisualDensity.compact,
                              onPressed: () {},
                              icon: Icon(Icons.question_mark),
                            ),
                            IconButton.filled(
                              color: AppColors.aquaTeal,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.greyAqua,
                              ),
                              iconSize: 16,
                              visualDensity: VisualDensity.compact,
                              onPressed: () {},
                              icon: Icon(Icons.favorite),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                "assets/PXL_20251014_011048644~2.jpg",
                              ),
                              radius: 62,
                            ),
                            Container(
                              width: 200,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Nguyen Dinh Hieu",
                                    style: TextStyle(
                                      fontSize: AppSizes.small,
                                      color: AppColors.light,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "IFBBQ natural",
                                    style: TextStyle(color: AppColors.light),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(4),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.light,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 14,
                                              color: AppColors.aquaTeal,
                                            ),
                                            Text("  5"),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(5),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.light,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.comment,
                                              size: 14,
                                              color: AppColors.aquaTeal,
                                            ),
                                            Text("  40"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    right: 0,
                    left: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.light,
                            borderRadius: BorderRadius.circular(16),
                            border: BoxBorder.all(
                              color: AppColors.aquaTeal,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.work, color: AppColors.aquaTeal),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "15 years",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("experience"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.light,
                            borderRadius: BorderRadius.circular(16),
                            border: BoxBorder.all(
                              color: AppColors.aquaTeal,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock_clock, color: AppColors.aquaTeal),
                              Text("Mon - Sat / 9:00-5:00"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Focus : ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "some note of the pt  "),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(),
                        Text(
                          "Profile",
                          style: TextStyle(
                            color: AppColors.aquaTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.small,
                          ),
                        ),
                        Divider(),
                        Text("Some thing profile"),
                        Divider(),
                        Text(
                          "Career Path",
                          style: TextStyle(
                            color: AppColors.aquaTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.small,
                          ),
                        ),
                        Divider(),
                        Text("Some thing profile"),
                        Divider(),
                        Text(
                          "Hightlights",
                          style: TextStyle(
                            color: AppColors.aquaTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.small,
                          ),
                        ),
                        Divider(),
                        Text("Some thing profile"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>Booking())),
              child: Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.light,
                  border: Border.all(color: AppColors.aquaTeal, width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Booking",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.small,
                    color: AppColors.aquaTeal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}