import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/feature/book/filterpage.dart';
import 'package:ontrain/feature/book/ptcvpage.dart';

class PTListpage extends StatelessWidget {
  const PTListpage({super.key, required this.pts});

  final List<PT> pts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.aquaTeal),
            height: 200,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 65,
                      child: Center(
                        child: Text(
                          "Personal Trainer",
                          style: TextStyle(
                            color: AppColors.light,
                            fontSize: AppSizes.medium,
                            fontWeight: FontWeight.bold,
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
                  ],
                ),
                Text("Find your PT", style: TextStyle(color: AppColors.light)),
                Container(
                  decoration: BoxDecoration(),
                  margin: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.light,
                      hint: Text(
                        "Seach ....",
                        style: TextStyle(
                          color: AppColors.aquaTeal,
                          fontSize: AppSizes.small,
                        ),
                      ),
                      // icon: Icon(Icons.search)
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Row(
          //   children: [
          //     IconButton.outlined(
          //       icon: Icon(Icons.line_weight),
          //       onPressed: () => {},
          //     ),
          //     IconButton.outlined(
          //       icon: Icon(Icons.line_weight),
          //       onPressed: () => {},
          //     ),
          //     IconButton.outlined(
          //       icon: Icon(Icons.line_weight),
          //       onPressed: () => {},
          //     ),
          //     IconButton.outlined(
          //       icon: Icon(Icons.line_weight),
          //       onPressed: () => {},
          //     ),
          //     IconButton.outlined(
          //       icon: Icon(Icons.line_weight),
          //       onPressed: () => {},
          //     ),
          //   ],
          // ),
          SizedBox(height: 35),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Sort By:"),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.aquaTeal,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "A - Z",
                          style: TextStyle(color: AppColors.light),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Filterpage()));
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.aquaTeal),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Filter",
                          style: TextStyle(
                            color: AppColors.aquaTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => {},
                      child: Text(
                        "Top Rating",
                        style: TextStyle(
                          color: AppColors.aquaTeal,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1, color: Colors.grey),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 35),
              child: ListView.builder(
                itemCount: pts.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundImage: AssetImage(
                                "assets/PXL_20251014_011048644~2.jpg",
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pts[index].name,
                                      style: TextStyle(
                                        color: AppColors.aquaTeal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSizes.small,
                                      ),
                                    ),
                                    Text(pts[index].Pnum),
                                  ],
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>PTCVPage()));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: BoxBorder.all(
                                            color: AppColors.aquaTeal,
                                          ),
                                        ),
                                        child: Text(
                                          "info",
                                          style: TextStyle(
                                            color: AppColors.aquaTeal,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Spacer(),

                                    Icon(
                                      Icons.schedule,
                                      color: AppColors.aquaTeal,
                                    ),
                                    Icon(
                                      Icons.question_mark,
                                      color: AppColors.aquaTeal,
                                    ),
                                    Icon(
                                      Icons.favorite,
                                      color: AppColors.aquaTeal,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
