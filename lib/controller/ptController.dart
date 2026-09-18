import 'package:flutter/material.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/bookingController.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/data/enum/ptStatus.dart';
import 'package:ontrain/repo/ptRepository.dart';

class PTController extends ChangeNotifier {
  final Ptrepository repo;
  final AuthController authController;
  final Bookingcontroller bookingController;

  PTController({
    required this.repo,
    required this.authController,
    required this.bookingController,
  });

  List<PT> _allPts = [];
  List<PT> _pts = [];

  List<PT> get pts => _pts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _currentQuery = "";
  String? _currentSpecialty;
  String? get currentSpecialty => _currentSpecialty;

  PT? _selectedPT;
  PT? get selectedPT => _selectedPT;

  void selectPT(PT pt) {
    _selectedPT = pt;
  }

  Future<void> getPTs() async {
    if (_allPts.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    final data = await repo.getPTsWithLimit(20);
    _allPts = data;
    _applyFilter();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshPTs() async {
    _isLoading = true;
    notifyListeners();
    final data = await repo.getPTsWithLimit(20);
    _allPts = data;
    _applyFilter();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> initController() async {
    await getPTs();
  }

  void filterByName(String query) {
    _currentQuery = query.trim().toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void filterBySpecialty(String? specialty) {
    _currentSpecialty = specialty;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    Iterable<PT> result = _allPts;
    if (_currentQuery.isNotEmpty) {
      result = result.where(
        (pt) => pt.fullName.toLowerCase().contains(_currentQuery) ||
                pt.headline.toLowerCase().contains(_currentQuery),
      );
    }
    if (_currentSpecialty != null) {
      final keyword = _currentSpecialty!.toLowerCase();
      result = result.where(
        (pt) => pt.bio.toLowerCase().contains(keyword) ||
                pt.headline.toLowerCase().contains(keyword),
      );
    }
    _pts = result.toList();
  }

  void clearFilter() {
    _currentQuery = "";
    _currentSpecialty = null;
    _pts = List.from(_allPts);
    notifyListeners();
  }

  void toggleFavorite(int index) {
    final pt = _pts[index];
    pt.isFavorite = !pt.isFavorite;
    notifyListeners();
  }

  Future<PT?> searchPTByName(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await repo.searchPTsByName(query);
      _pts = data;
      _isLoading = false;
      notifyListeners();
      return data.isNotEmpty ? data.first : null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}