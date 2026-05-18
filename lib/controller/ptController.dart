import 'package:flutter/material.dart';
import 'package:ontrain/data/object/pt.dart';
import 'package:ontrain/repo/ptRepository.dart';

class PTController extends ChangeNotifier {
  final Ptrepository repo;
  PTController(this.repo);

  /// The master list of all PTs fetched from the source.
  List<PT> _allPts = [];

  /// The list currently displayed in the UI (filtered).
  List<PT> _pts = [];

  /// Getter for the UI to consume.
  List<PT> get pts => _pts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _currentQuery = "";

  /// Fetches PTs and updates both master and display lists.
  Future<void> getPTs() async {
    _isLoading = true;
    notifyListeners();
    final data = await repo.getPTsWithLimit(20);
    _allPts = data;
      _applyFilter();
    _isLoading = false;
    notifyListeners();
  }

  /// A "so good" filter that handles case-insensitivity, 
  /// leading/trailing spaces, and empty queries.
  void filterByName(String query) {
    _currentQuery = query.trim().toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  /// Internal logic to apply the current search query to the master list.
  void _applyFilter() {
    if (_currentQuery.isEmpty) {
      _pts = List.from(_allPts);
    } else {
      _pts = _allPts.where((pt) {
        final nameMatch = pt.name.toLowerCase().contains(_currentQuery);
        return nameMatch;
      }).toList();
    }
  }

  /// Resets the filter to show everyone.
  void clearFilter() {
    _currentQuery = "";
    _pts = List.from(_allPts);
    notifyListeners();
  }

  void toggleFavorite(int index) {
    final pt = _pts[index];
    pt.isFavorite = !(pt.isFavorite ?? false);
    notifyListeners();
  }
}
