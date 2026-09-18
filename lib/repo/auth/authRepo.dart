import 'package:ontrain/data/enum/userRole.dart';
import 'package:ontrain/data/object/user.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:ontrain/repo/errorHandle/authErrorHandle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authrepo {
  final SupabaseClient _supabaseClient;

  Authrepo({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<Result<User>> signIn(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        return Result.failure(
          RepoError(message: 'Không tìm thấy người dùng', code: 500),
        );
      }
      return Result.success(_supabaseClient.auth.currentUser!);
    } catch (e) {
      return Result.failure(
        AuthErrorHandle.mapError(e),
      );
    }
  }

  Future<Result<User>> signUp(
    String email,
    String password,
    UserRole role,
    String fullName,
  ) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        password: password,
        email: email,
      );
      if (response.user == null) {
        return Result.failure(
          RepoError(message: 'Failed to sign up', code: 500),
        );
      }

      await _supabaseClient.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'role': role.dbValue,
        'timezone': 'Asia/Ho_Chi_Minh',
        'locale': 'vi',
        'is_verified': false,
      });
      return Result.success(response.user!);
    } catch (e) {
      return Result.failure(AuthErrorHandle.mapError(e));
    }
  }

  Future<Result<String>> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      return Result.success('signed out');
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Failed to sign out', code: 500),
      );
    }
  }

  String? getCurrentUserEmail() {
    final user = _supabaseClient.auth.currentUser;
    return user?.email;
  }

  Future<Result<UserData>> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return Result.failure(
          RepoError(message: 'No user signed in', code: 404),
        );
      }
      final userData = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      if (userData.isEmpty) {
        return Result.failure(
          RepoError(message: 'User data not found', code: 404),
        );
      }
      return Result.success(UserData.fromMap(userData));
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Failed to get current user', code: 500),
      );
    }
  }
}