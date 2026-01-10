import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.aquaTeal),
            width: double.infinity,
            height: 75,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    "Review",
                    style: TextStyle(
                      color: AppColors.light,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.small,
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
                      icon: Icon(Icons.arrow_back_ios, color: AppColors.light),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("Review Your Personal Trainer"),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                "assets/PXL_20251014_011048644~2.jpg",
              ),
              radius: 65,
            ),
          ),
          Text(
            "Dinh Hieu",
            style: TextStyle(
              color: AppColors.aquaTeal,
              fontSize: AppSizes.small,
            ),
          ),
          Text("IFBBQ"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(8),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.aquaTeal,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: AppColors.light),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: BoxBorder.all(color: AppColors.aquaTeal),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: AppColors.aquaTeal),
                    Icon(Icons.star, color: AppColors.aquaTeal),
                    Icon(Icons.star, color: AppColors.aquaTeal),
                    Icon(Icons.star, color: AppColors.aquaTeal),
                    Icon(Icons.star, color: AppColors.aquaTeal),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.all(30),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter your reason here.....",
                filled: true,
                fillColor: AppColors.greyAqua,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 100),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.aquaTeal,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Center(
              child: Text(
                "Add Review",
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
    );
  }
}
