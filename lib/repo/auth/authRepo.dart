import 'package:ontrain/data/enum/userRole.dart';
import 'package:ontrain/data/object/user.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

  class Authrepo {
    final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<Result<User>> signIn(String email, String password) async {

    try {
      await _supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      return Result.success(_supabaseClient.auth.currentUser!);
    } catch (e) {
      print('Error signing in: $e');
      return Result.failure(RepoError(message: 'Failed to sign in', code: 500));
    }
  }

  Future<Result<User>> signUp(
    String email,
    String password,
    UserRole role,
    String name
  ) async {
    try {
      final respone = await _supabaseClient.auth.signUp(
        password: password,
        email: email,
      );
      if (respone.user == null) {
        return Result.failure(RepoError(message: 'Failed to sign up', code: 500));
      }

      await _supabaseClient.from("profile").insert({
        "user_id": respone.user!.id,
        "email": email,
        "role": role.name,
        "name": name,
      });
      return Result.success(respone.user);
    } catch (e) {
      print('Error signing up: $e');
      return Result.failure(RepoError(message: 'Failed to sign up', code: 500));
    }
  }

  Future<Result<String>> signOut() async {
    try {
      await _supabaseClient.auth.signOut();

      
      return Result.success("signed out ");
    } catch (e) {
      print('Error signing out: $e');
      return Result.failure(RepoError(message: 'Failed to sign out', code: 500));
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
        return Result.failure(RepoError(message: 'No user signed in', code: 404));
      }
     final userData= await _supabaseClient.from("profile").select().eq("user_id", user.id).single();



      return Result.success(UserData.fromMap(userData));
    } catch (e) {
      print('Error getting current user: $e');
      return Result.failure(RepoError(message: 'Failed to get current user', code: 500));
    }
  }
}
