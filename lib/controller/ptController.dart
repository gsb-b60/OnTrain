import 'package:flutter/material.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/bookingController.dart';
import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/repo/ptRepository.dart';

class PTController extends ChangeNotifier {
  final Ptrepository repo;
  final AuthController authController;
  final Bookingcontroller bookingController;
  
  PTController(
    this.repo,
    this.authController,
    this.bookingController
  );

  List<PT> _allPts = [];
  List<PT> _pts = [];

  /// Getter for the UI to consume.
  List<PT> get pts => _pts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _currentQuery = "";
  String? _currentSpecialty;
  String? get currentSpecialty => _currentSpecialty;

  PT? _selectedPT=PT(id: "id", name: "Name", phoneNumber: "Phone Number", status: PTState.accepted);
  PT? get selectedPT => _selectedPT;

  void selectPT(PT pt) { 
    _selectedPT = pt;
  }

  /// Fetches PTs and updates both master and display lists.
  Future<void> getPTs() async {
    if(_allPts.isNotEmpty) return;
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

  /// A "so good" filter that handles case-insensitivity,
  /// leading/trailing spaces, and empty queries.
  void filterByName(String query) {
    _currentQuery = query.trim().toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  /// Sets the active specialty filter (or clears it with null).
  /// Matched against the PT's `notes` ("Focus") field.
  void filterBySpecialty(String? specialty) {
    _currentSpecialty = specialty;
    _applyFilter();
    notifyListeners();
  }

  /// Internal logic to apply the current search query to the master list.
  void _applyFilter() {
    Iterable<PT> result = _allPts;
    if (_currentQuery.isNotEmpty) {
      result = result.where(
        (pt) => pt.name.toLowerCase().contains(_currentQuery),
      );
    }
    if (_currentSpecialty != null) {
      final keyword = _currentSpecialty!.toLowerCase();
      result = result.where(
        (pt) => (pt.notes ?? '').toLowerCase().contains(keyword),
      );
    }
    _pts = result.toList();
  }

  /// Resets the filter to show everyone.
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
}
