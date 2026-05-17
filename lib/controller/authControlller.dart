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
  UserData? user;
  String? error;

  Future<Result< void>> signIn(String email, String password) async {
    return await repo.signIn(email, password);
  }

  Future<Result< void>> signUp(
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
    state = ViewState.loading;
    notifyListeners();

    final result = await repo.getCurrentUser();

    if (result.isSuccess) {
      user = result.data;
      state = ViewState.success;
    } else {
      error = result.error!.message;
      state = ViewState.error;
    }

    notifyListeners();
  }
}
