import 'package:ontrain/data/object/review.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewRepository {
  final SupabaseClient _supabaseClient;

  ReviewRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<Result<void>> submitReview(Review review) async {
    try {
      // Check if review already exists for this booking
      final existing = await _supabaseClient
          .from('reviews')
          .select('id')
          .eq('booking_id', review.bookingId)
          .maybeSingle();

      if (existing != null) {
        return Result.failure(
          RepoError(message: 'Review already exists for this booking', code: 409),
        );
      }

      await _supabaseClient
          .from('reviews')
          .insert(review.toInsertMap());

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error submitting review: $e', code: 500),
      );
    }
  }

  Future<Result<List<Review>>> fetchReviewsForPT(String ptId) async {
    try {
      final response = await _supabaseClient
          .from('reviews')
          .select()
          .eq('pt_id', ptId)
          .order('created_at', ascending: false);

      final reviews = response.map((e) => Review.fromMap(e)).toList();

      return Result.success(reviews);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching reviews: $e', code: 500),
      );
    }
  }

  Future<Result<Review?>> fetchReviewForBooking(String bookingId) async {
    try {
      final response = await _supabaseClient
          .from('reviews')
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (response == null) {
        return Result.success(null);
      }

      return Result.success(Review.fromMap(response));
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching review: $e', code: 500),
      );
    }
  }
}