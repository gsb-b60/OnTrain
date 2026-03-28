import 'package:flutter/cupertino.dart';
import 'package:ontrain/data/enum/userRole.dart';
import 'package:ontrain/repo/auth/authRepo.dart';

class Authcontrolller extends ChangeNotifier {
  Authrepo repo;
  Authcontrolller(this.repo);



  Future<void> signIn(String email, String password) async {
    try {
      await repo.signIn(email, password);
    } catch (e) {
      print('Error signing in: $e');
    }
  }
  Future<void> signUp(
    String email, 
    String password, 
    UserRole role,
    String name
  ) async {
    try {
      await repo.signUp(email, password, role,name);
    } catch (e) {
      print('Error signing up: $e');
    }
  }
  Future<void> signOut() async {
    try {
      await repo.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      return repo.getCurrentUserEmail();
    } catch (e) {
      print('Error getting current user email: $e');
      return null;
    }
  }
}
