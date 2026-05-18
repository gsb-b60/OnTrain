import 'package:ontrain/data/object/booking.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<Result<List<Booking>>> fetchBookingByPTID(String ptId) async {
    try {
      final response = await _supabaseClient
          .from("Booking")
          .select("""
                    *,
                    PT(*),
                    client(*)
                  """)
          .eq("pt_id", ptId);

      if (response == null || response.isEmpty) {
        return Result.failure(
          RepoError(message: 'Failed to fetch bookings', code: 500),
        );
      }

      final bookings = response.map((e) => Booking.fromMap(e)).toList();
      print("Fetched bookings: $bookings");
      return Result.success(bookings);
    } catch (e) {
      print("Error fetching bookings: $e");
      return Result.failure(
        RepoError(message: 'Error fetching bookings: $e', code: 500),
      );
    }
  }
}
