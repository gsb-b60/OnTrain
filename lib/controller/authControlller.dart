import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:ontrain/data/enum/userRole.dart';
import 'package:ontrain/data/object/user.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:ontrain/model/stateEnum.dart';
import 'package:ontrain/repo/auth/authRepo.dart';

class AuthController extends ChangeNotifier {
  Authrepo repo;
  AuthController(this.repo);
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
    String name,
  ) async {
    return await repo.signUp(email, password, role, name);
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
