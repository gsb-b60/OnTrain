import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/bookingController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/enum/bookingStatus.dart';
import 'package:ontrain/feature/book/cancelsess.dart';
import 'package:ontrain/feature/book/review.dart';
import 'package:ontrain/feature/book/yoursessionpage.dart';
import 'package:provider/provider.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  int pageIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      final bookingController = context.read<Bookingcontroller>();
      final clientId = authController.user?.id;
      if (clientId != null) {
        bookingController.fetchBookingsForClient(clientId);
      }
    });
  }

  void _changePage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 85,
                decoration: BoxDecoration(color: AppColors.aquaTeal),
                child: Center(
                  child: Text(
                    'All Appointment',
                    style: TextStyle(
                      color: AppColors.light,
                      fontSize: AppSizes.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            child: Consumer<Bookingcontroller>(
              builder: (context, controller, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TabButton(
                      label: 'Completed',
                      count: controller.completed.length,
                      isSelected: pageIndex == 0,
                      onTap: () => _changePage(0),
                    ),
                    _TabButton(
                      label: 'Upcoming',
                      count: controller.upcoming.length,
                      isSelected: pageIndex == 1,
                      onTap: () => _changePage(1),
                    ),
                    _TabButton(
                      label: 'Cancelled',
                      count: controller.cancelled.length,
                      isSelected: pageIndex == 2,
                      onTap: () => _changePage(2),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<Bookingcontroller>(
              builder: (context, controller, child) {
                final lists = [
                  controller.completed,
                  controller.upcoming,
                  controller.cancelled,
                ];
                return lists[pageIndex].isEmpty
                    ? Center(
                        child: Text(
                          _emptyMessage(pageIndex),
                          style: TextStyle(color: AppColors.gray700),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: lists[pageIndex].length,
                        itemBuilder: (context, index) {
                          final booking = lists[pageIndex][index];
                          return _BookingCard(
                            booking: booking,
                            accent: _accentForStatus(booking.status),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _emptyMessage(int index) {
    switch (index) {
      case 0:
        return 'No completed sessions yet';
      case 1:
        return 'No upcoming sessions';
      case 2:
        return 'No cancelled sessions';
      default:
        return '';
    }
  }

  Color _accentForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return AppColors.aquaTeal;
      case BookingStatus.confirmed:
      case BookingStatus.inProgress:
        return AppColors.aquaTeal;
      case BookingStatus.cancelledByClient:
      case BookingStatus.cancelledByPt:
        return AppColors.gray500;
      case BookingStatus.disputed:
        return Colors.orange;
      case BookingStatus.noShowClient:
      case BookingStatus.noShowPt:
        return Colors.red;
      default:
        return AppColors.aquaTeal;
    }
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isSelected ? AppColors.aquaTeal : AppColors.light,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.light : AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.light : AppColors.aquaTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: isSelected ? AppColors.aquaTeal : AppColors.light,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.accent,
  });

  final Booking booking;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final pt = booking.pt;
    final displayName = pt?.name ?? 'Personal Trainer';
    final displayNote = booking.clientNotes?.isNotEmpty == true
        ? booking.clientNotes!
        : 'Focus: ${pt?.notes ?? '...'}';

    return Column(
      children: [
        const Divider(),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PT. ${displayName}',
                        style: TextStyle(
                          color: AppColors.aquaTeal,
                          fontSize: AppSizes.small,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('IFBBQ'),
                    ],
                  ),
                  const Spacer(),
                  _StatusChip(
                    label: _statusLabel(booking.status),
                    color: accent,
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.alarm, color: AppColors.aquaTeal),
                        Text(
                          '${DateFormat('EEE dd/MM/yyyy').format(booking.startAt)}  '
                          '${DateFormat('HH:mm').format(booking.startAt)} - '
                          '${DateFormat('HH:mm').format(booking.endAt)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (booking.status == BookingStatus.completed)
                    Container(
                      height: 35,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.aquaTeal),
                      ),
                      child: Center(
                        child: Text(
                          'ReBook',
                          style: TextStyle(
                            fontSize: AppSizes.small,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  if (booking.status == BookingStatus.completed)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReviewPage()),
                      ),
                      child: Container(
                        height: 35,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.aquaTeal),
                        ),
                        child: Center(
                          child: Text(
                            'Review',
                            style: TextStyle(
                              fontSize: AppSizes.small,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (booking.status == BookingStatus.confirmed ||
                      booking.status == BookingStatus.inProgress)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YourSessionPage(booking: booking),
                        ),
                      ),
                      child: Container(
                        height: 35,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.aquaTeal),
                        ),
                        child: Center(
                          child: Text(
                            'Details',
                            style: TextStyle(
                              fontSize: AppSizes.small,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (booking.status == BookingStatus.confirmed ||
                      booking.status == BookingStatus.inProgress)
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CancelAppoint(bookingId: booking.id),
                          ),
                        );
                      },
                      icon: Icon(Icons.cancel, color: AppColors.aquaTeal),
                    ),
                  if (booking.status == BookingStatus.cancelledByClient ||
                      booking.status == BookingStatus.cancelledByPt)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReviewPage()),
                      ),
                      child: Container(
                        height: 35,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.aquaTeal,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Add Review',
                            style: TextStyle(
                              fontSize: AppSizes.small,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Upcoming';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelledByClient:
        return 'Cancelled by Client';
      case BookingStatus.cancelledByPt:
        return 'Cancelled by PT';
      case BookingStatus.noShowClient:
        return 'No Show (Client)';
      case BookingStatus.noShowPt:
        return 'No Show (PT)';
      case BookingStatus.disputed:
        return 'Disputed';
      case BookingStatus.refunded:
        return 'Refunded';
      case BookingStatus.expired:
        return 'Expired';
    }
  }
}

/// Small rounded badge used to label a session's status.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.small - 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}