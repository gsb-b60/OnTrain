import 'package:ontrain/data/object/payment.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRepository {
  final SupabaseClient _supabaseClient;

  PaymentRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<Result<Payment>> createPayment(Payment payment) async {
    try {
      final response = await _supabaseClient
          .from('payments')
          .insert(payment.toInsertMap())
          .select()
          .single();

      return Result.success(Payment.fromMap(response));
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error creating payment: $e', code: 500),
      );
    }
  }

  Future<Result<Payment?>> fetchPaymentByBooking(String bookingId) async {
    try {
      final response = await _supabaseClient
          .from('payments')
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (response == null) {
        return Result.success(null);
      }

      return Result.success(Payment.fromMap(response));
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching payment: $e', code: 500),
      );
    }
  }

  Future<Result<List<Payment>>> fetchPaymentsByClient(String clientId) async {
    try {
      final response = await _supabaseClient
          .from('payments')
          .select()
          .eq('client_id', clientId)
          .order('created_at', ascending: false);

      final payments = response.map((e) => Payment.fromMap(e)).toList();

      return Result.success(payments);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching payments: $e', code: 500),
      );
    }
  }

  Future<Result<void>> updatePaymentStatus(
    String paymentId,
    PaymentStatus newStatus,
  ) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus.dbValue,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (newStatus == PaymentStatus.released) {
        updateData['released_at'] = DateTime.now().toIso8601String();
      } else if (newStatus == PaymentStatus.refunded) {
        updateData['refunded_at'] = DateTime.now().toIso8601String();
      }

      await _supabaseClient
          .from('payments')
          .update(updateData)
          .eq('id', paymentId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error updating payment status: $e', code: 500),
      );
    }
  }

  Future<Result<void>> refundPayment(String paymentId) async {
    return updatePaymentStatus(paymentId, PaymentStatus.refunded);
  }
}