import 'package:flutter/widgets.dart' hide Notification;
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/data/object/notification.dart' as ontrain_notification;
import 'package:ontrain/model/stateEnum.dart';
import 'package:ontrain/repo/notificationRepository.dart';

class NotificationController extends ChangeNotifier {
  final NotificationRepository repository;
  final AuthController authController;

  NotificationController({
    required this.repository,
    required this.authController,
  });

  List<ontrain_notification.Notification> _notifications = [];
  List<ontrain_notification.Notification> get notifications => _notifications;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _error;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    final userId = authController.user?.id;
    if (userId == null) {
      _error = 'User not authenticated';
      _state = ViewState.error;
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    final result = await repository.fetchNotifications(userId: userId);
    if (result.isSuccess) {
      _notifications = result.data ?? [];
      _state = ViewState.success;
    } else {
      _notifications = [];
      _error = result.error?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> fetchUnreadCount() async {
    final userId = authController.user?.id;
    if (userId == null) return;

    final result = await repository.fetchUnreadCount(userId);
    if (result.isSuccess) {
      _unreadCount = result.data ?? 0;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await repository.markAsRead(notificationId);
    if (result.isSuccess) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final userId = authController.user?.id;
    if (userId == null) return;

    final result = await repository.markAllAsRead(userId);
    if (result.isSuccess) {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    }
  }

  void onNotificationReceived(ontrain_notification.Notification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }
}