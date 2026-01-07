
import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';

class Filterpage extends StatelessWidget {
  const Filterpage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 65,
            width: double.infinity,
            child: Stack(
              children: [
                Center(child: Text("Filters")),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.arrow_back_ios),
                ),
              ],
            ),
          ),
          Row(children: [Text("Available today")]),
          Text("Gender"),
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: Text("Male")),
              ElevatedButton(onPressed: () {}, child: Text("Male")),
            ],
          ),
          Divider(),
          Row(
            children: [
              Text("Top Rated"),
              Container(
                child: Row(
                  children: [
                    Icon(Icons.start),
                    Icon(Icons.start),
                    Icon(Icons.start),
                    Icon(Icons.start),
                    Icon(Icons.start),
                  ],
                ),
              ),
            ],
          ),
          Divider(),
          Text(
            "Work Experience (Years)",
            style: TextStyle(
              color: AppColors.aquaTeal,
              fontSize: AppSizes.small,
            ),
          ),
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: Text("1-5")),
              ElevatedButton(onPressed: () {}, child: Text("6-9")),
              ElevatedButton(onPressed: () {}, child: Text("10>")),
            ],
          ),
          Container(
            height: 120,
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.aquaTeal,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Text("data", style: TextStyle(color: AppColors.aquaTeal)),
          Slider(value: 1, onChanged: (double a) {}),
        ],
      ),
    );
  }
}