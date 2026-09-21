import 'package:ontrain/data/object/notification.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  final SupabaseClient _supabaseClient;

  NotificationRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<Result<List<Notification>>> fetchNotifications({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final notifications = response.map((e) => Notification.fromMap(e)).toList();

      return Result.success(notifications);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching notifications: $e', code: 500),
      );
    }
  }

  Future<Result<int>> fetchUnreadCount(String userId) async {
    try {
      final response = await _supabaseClient
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .count();

      return Result.success(response.count ?? 0);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching unread count: $e', code: 500),
      );
    }
  }

  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error marking notification as read: $e', code: 500),
      );
    }
  }

  Future<Result<void>> markAllAsRead(String userId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error marking all notifications as read: $e', code: 500),
      );
    }
  }
}