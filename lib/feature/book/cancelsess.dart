import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';

enum CancelReason { Rescheduling, Weather, work, others }

class CancelAppoint extends StatefulWidget {
  const CancelAppoint({super.key});

  @override
  State<CancelAppoint> createState() => _CancelAppointState();
}

class _CancelAppointState extends State<CancelAppoint> {
  CancelReason? _groupValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
                      "Cancel appointment",
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
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.light,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  RadioGroup(
                    onChanged: (bool? newvalue) {},
                    child: Column(children: []),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      "you want to cancel the appointment ?? are you sure",
                    ),
                  ),

                  RadioGroup(
                    onChanged: (CancelReason? newvalue) {
                      setState(() {
                        _groupValue = newvalue;
                      });
                    },
                    groupValue: _groupValue,
                    child: Column(
                      children: [
                        RadioListTile<CancelReason>(
                          title: Text("Rescheduling"),
                          value: CancelReason.Rescheduling,
                          
                        ),
                        RadioListTile<CancelReason>(
                          title: Text("Unexpected Work"),
                          value: CancelReason.work,
                          
                        ),
                        RadioListTile<CancelReason>(
                          title: Text("Weather conditions"),
                          value: CancelReason.Weather,
                          
                        ),
                        RadioListTile<CancelReason>(
                          title: Text("Others"),
                          value: CancelReason.others,
                          
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "it is ok to cancel if you annouce soon enough",
                      style: TextStyle(color: AppColors.aquaTeal),
                    ),
                  ),
                  Container(
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
                ],
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
                  "Cancel Appointment",
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
      ),
    );
  }
}
