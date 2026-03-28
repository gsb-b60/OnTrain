import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key,
  
  required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(gradient: AppGradients.brand),
      child: Stack(
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppSizes.semiLarge,
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
    );
  }
}
