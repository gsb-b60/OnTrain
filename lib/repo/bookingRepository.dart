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

      // An empty result is a valid state (no bookings yet), not an error.
      final bookings = response.map((e) => Booking.fromMap(e)).toList();
      return Result.success(bookings);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching bookings: $e', code: 500),
      );
    }
  }

  Future<Result<void>> insertBooking(Booking booking) async {
    try {
      await _supabaseClient
          .from("Booking")
          .insert(booking.toInsertMap()).select();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        
        RepoError(message: 'Error inserting booking: $e', code: 500),
      );
    }
  }
}
