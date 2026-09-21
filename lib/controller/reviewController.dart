import 'package:flutter/widgets.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/data/object/review.dart';
import 'package:ontrain/model/stateEnum.dart';
import 'package:ontrain/repo/reviewRepository.dart';

class ReviewController extends ChangeNotifier {
  final ReviewRepository repository;
  final AuthController authController;

  ReviewController({
    required this.repository,
    required this.authController,
  });

  List<Review> _ptReviews = [];
  List<Review> get ptReviews => _ptReviews;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _error;
  String? get error => _error;

  Future<bool> submitReview({
    required String bookingId,
    required String ptId,
    required int rating,
    String? comment,
  }) async {
    final clientId = authController.user?.id;
    if (clientId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    if (rating < 1 || rating > 5) {
      _error = 'Rating must be between 1 and 5';
      notifyListeners();
      return false;
    }

    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    final review = Review(
      bookingId: bookingId,
      clientId: clientId,
      ptId: ptId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    final result = await repository.submitReview(review);
    if (result.isSuccess) {
      _state = ViewState.success;
      notifyListeners();
      return true;
    } else {
      _state = ViewState.error;
      _error = result.error?.message ?? 'Failed to submit review';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchPTReviews(String ptId) async {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    final result = await repository.fetchReviewsForPT(ptId);
    if (result.isSuccess) {
      _ptReviews = result.data ?? [];
      _state = ViewState.success;
    } else {
      _ptReviews = [];
      _error = result.error?.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }
}