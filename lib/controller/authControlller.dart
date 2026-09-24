import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:ontrain/data/enum/userRole.dart';
import 'package:ontrain/data/object/user.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:ontrain/model/stateEnum.dart';
import 'package:ontrain/repo/auth/authRepo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends ChangeNotifier {
  final Authrepo repo;
  AuthController({Authrepo? repo, SupabaseClient? supabaseClient})
    : repo = repo ?? Authrepo(supabaseClient: supabaseClient);
  ViewState state = ViewState.idle;
  UserData? _user;
  String? error;
  UserData? get user => _user;

  Future<Result<void>> signIn(String email, String password) async {
    if (state != ViewState.loading) {
      state = ViewState.loading;
      error = null;
      notifyListeners();
    }
    final result = await repo.signIn(email, password);
    if (result.isSuccess) {
      state = ViewState.success;
    } else {
      error = result.error?.message;
      state = ViewState.error;
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> signUp(
    String email,
    String password,
    UserRole role,
    String fullName,
    DateTime dateOfBirth,
  ) async {
    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedName.isEmpty ||
        trimmedEmail.isEmpty ||
        trimmedPassword.isEmpty) {
      error = 'Hãy điền đầy đủ thông tin và chọn loại tài khoản';
      state = ViewState.error;
      notifyListeners();
      return Result.failure(RepoError(message: error!, code: 400));
    }

    if (state != ViewState.loading) {
      state = ViewState.loading;
      error = null;
      notifyListeners();
    }

    try {
      final result = await repo.signUp(
        trimmedEmail,
        trimmedPassword,
        role,
        trimmedName,
        dateOfBirth,
      );
      if (result.isSuccess) {
        state = ViewState.success;
      } else {
        error = result.error?.message;
        state = ViewState.error;
      }
      notifyListeners();
      return result;
    } catch (e) {
      error = e.toString();
      state = ViewState.error;
      notifyListeners();
      return Result.failure(RepoError(message: error!, code: 500));
    }
  }

  Future<void> signOut() async {
    await repo.signOut();
  }

  Future<void> getCurrentUserData() async {
    if (state != ViewState.loading) {
      state = ViewState.loading;
      notifyListeners();
    }

    final result = await repo.getCurrentUser();

    if (result.isSuccess) {
      _user = result.data;
      state = ViewState.success;
    } else {
      error = result.error!.message;
      state = ViewState.error;
    }

    notifyListeners();
  }
}
