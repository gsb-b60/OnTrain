import 'dart:io';

import 'package:ontrain/model/error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorHandle {
  static RepoError mapError(dynamic e) {
    if (e is AuthException) {
      final msg = e.message.toLowerCase();

      // 🌐 Network
      if (msg.contains('socketexception') ||
          msg.contains('failed host lookup')) {
        return RepoError(message: 'Không có kết nối mạng', code: 0);
      }

      // 🔐 Login
      if (msg == 'invalid login credentials') {
        return RepoError(message: 'Email hoặc mật khẩu sai', code: 401);
      }

      if (msg == 'email not confirmed') {
        return RepoError(
          message: 'Vui lòng xác nhận email trước khi đăng nhập',
          code: 403,
        );
      }

      // 📝 Signup
      if (msg.contains('user already registered') ||
          msg.contains('already registered')) {
        return RepoError(message: 'Email đã được sử dụng', code: 409);
      }

      if (msg.contains('password')) {
        return RepoError(
          message: 'Mật khẩu quá yếu (tối thiểu 6 ký tự)',
          code: 400,
        );
      }

      if (msg.contains('invalid email')) {
        return RepoError(message: 'Email không hợp lệ', code: 400);
      }

      // fallback auth
      return RepoError(message: e.message, code: 401);
    }

    // 🌐 Network fallback
    if (e is SocketException) {
      return RepoError(message: 'Không có kết nối mạng', code: 0);
    }

    // ❓ Unknown
    return RepoError(message: 'Có lỗi xảy ra, thử lại sau', code: 500);
  }
}
