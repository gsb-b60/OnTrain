import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';

class CancelAppoint extends StatefulWidget {
  const CancelAppoint({super.key});

  @override
  State<CancelAppoint> createState() => _CancelAppointState();
}

class _CancelAppointState extends State<CancelAppoint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.aquaTeal),
            width: double.infinity,
            height: 65,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    "Cancel appointment",
                    style: TextStyle(
                      color: AppColors.light,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_back_ios),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text("you want to cancel the appointment ?? are you sure"),
          Row(
            children: [
              Checkbox(value: true, onChanged: (bool? newvalue) {}),
              Text("Rescheduling"),
            ],
          ),
          Row(
            children: [
              Checkbox(value: true, onChanged: (bool? newvalue) {}),
              Text("Weather conditions"),
            ],
          ),
          Row(
            children: [
              Checkbox(value: true, onChanged: (bool? newvalue) {}),
              Text("Unexpected Work"),
            ],
          ),
          Row(
            children: [
              Checkbox(value: true, onChanged: (bool? newvalue) {}),
              Text("Others"),
            ],
          ),
          Text("it is ok to cancel if you annouce soon enough"),
          TextField(

          )
        ],
      ),
    );
  }
}
