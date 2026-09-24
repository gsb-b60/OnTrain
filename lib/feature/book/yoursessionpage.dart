import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/feature/book/cancelsess.dart';

class YourSessionPage extends StatelessWidget {
  const YourSessionPage({
    super.key,
    this.booking,
    this.pt,
  });

  /// The booking being confirmed/viewed. Falls back to part-less display
  /// when null (e.g. when opened from a mock-flow screen).
  final Booking? booking;

  /// The PT the session belongs to. Falls back to the booking's PT.
  final PT? pt;

  PT? get _pt => pt ?? booking?.pt;
  DateTime get _time =>
      booking?.startTime ??
      booking?.createdAt ??
      DateTime.now();

  @override
  Widget build(BuildContext context) {
    final displayName = _pt?.name ?? "Personal Trainer";
    final displayNote =
        booking?.notes?.isNotEmpty == true
            ? booking!.notes!
            : "Focus : ${_pt?.notes ?? "..."}";
    final displayDate = DateFormat("dd/MM/yyyy").format(_time);
    final displayClock = DateFormat("EEE hh:mm a").format(_time);

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
                        SizedBox(
                          height: 65,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              "Booking Details",
                              style: TextStyle(
                                color: AppColors.light,
                                fontSize: AppSizes.semiLarge,
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
                                  displayName,
                                  style: TextStyle(
                                    color: AppColors.aquaTeal,
                                    fontSize: AppSizes.medium,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("IFBBQ"),
                                Row(
                                  children: [
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
                                          (_pt?.isFavorite == true)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
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
                                displayDate,
                                style: TextStyle(
                                  color: AppColors.light,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.check_circle_rounded,
                                size: 32,
                                color: AppColors.aquaTeal,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final bookingId = booking?.id;
                                if (bookingId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CancelAppoint(
                                        bookingId: bookingId,
                                      ),
                                    ),
                                  );
                                }
                              },
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
                          child: Text(displayClock),
                        ),
                      ],
                    ),
                    Column(
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
                          Divider(),
                          Text(
                            displayNote,
                            style: TextStyle(
                              color: AppColors.gray700,
                              fontSize: AppSizes.small,
                            ),
                          ),
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
                    onTap: () => Navigator.pop(context),
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