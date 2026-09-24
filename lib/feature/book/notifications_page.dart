import 'package:flutter/material.dart' hide Notification;
import 'package:ontrain/controller/notificationController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/notification.dart' as ontrain_notification;
import 'package:intl/intl.dart';
import 'package:ontrain/model/stateEnum.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationController>().fetchNotifications();
      context.read<NotificationController>().fetchUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.aquaTeal,
        foregroundColor: AppColors.light,
        actions: [
          Consumer<NotificationController>(
            builder: (context, controller, child) {
              if (controller.unreadCount > 0) {
                return TextButton(
                  onPressed: () => controller.markAllAsRead(),
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(color: AppColors.light),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationController>(
        builder: (context, controller, child) {
          if (controller.state == ViewState.loading && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.state == ViewState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.error ?? 'Error loading notifications',
                    style: TextStyle(color: AppColors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.fetchNotifications();
                      controller.fetchUnreadCount();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: AppColors.gray700,
                      fontSize: AppSizes.medium,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _NotificationTile(
                notification: notification,
                onTap: () async {
                  if (!notification.isRead) {
                    await controller.markAsRead(notification.id);
                  }
                  _handleNotificationTap(context, notification);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, ontrain_notification.Notification notification) {
    // Navigate based on notification type and data
    final data = notification.data;
    if (data == null) return;

    final bookingId = data['booking_id'] as String?;
    final type = notification.type;

    if (bookingId != null) {
      switch (type) {
        case 'booking_created':
        case 'booking_confirmed':
        case 'booking_cancelled':
        case 'booking_completed':
          Navigator.pushNamed(context, '/session-detail', arguments: bookingId);
          break;
        case 'dispute_opened':
          Navigator.pushNamed(context, '/dispute', arguments: bookingId);
          break;
        case 'payout_completed':
          Navigator.pushNamed(context, '/earnings');
          break;
      }
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final ontrain_notification.Notification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? AppColors.light : AppColors.aquaTeal.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(type: notification.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: AppSizes.small + 2,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.aquaTeal,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: AppColors.gray700,
                        fontSize: AppSizes.small,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(notification.createdAt),
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (type) {
      case 'booking_created':
      case 'booking_confirmed':
        icon = Icons.calendar_month;
        color = AppColors.aquaTeal;
        break;
      case 'booking_cancelled':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'booking_completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'no_show':
        icon = Icons.person_off;
        color = Colors.orange;
        break;
      case 'dispute_opened':
        icon = Icons.gavel;
        color = Colors.purple;
        break;
      case 'payout_completed':
      case 'payout_failed':
        icon = Icons.account_balance_wallet;
        color = Colors.blue;
        break;
      case 'review_received':
        icon = Icons.star;
        color = Colors.amber;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.gray500;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}