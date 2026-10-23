import 'package:ontrain/data/object/payout.dart';
import 'package:ontrain/data/enum/payoutStatus.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PayoutRepository {
  final SupabaseClient _supabaseClient;

  PayoutRepository({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Requests a payout of the full available balance.
  ///
  /// The database function reads the PT's bank details, checks the minimum,
  /// inserts the payout and links all available earnings atomically.
  Future<Result<String>> requestPayout() async {
    try {
      final payoutId = await _supabaseClient.rpc<String>('request_payout');

      return Result.success(payoutId);
    } catch (e) {
      return Result.failure(
        RepoError(message: _payoutErrorMessage(e), code: 500),
      );
    }
  }

  String _payoutErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('bank details not configured')) {
      return 'Bank details not configured in profile';
    }
    if (message.contains('below minimum payout')) {
      return 'Available balance is below the minimum payout';
    }
    if (message.contains('no available earnings')) {
      return 'No available earnings to withdraw';
    }
    if (message.contains('not authenticated')) {
      return 'PT not authenticated';
    }
    return 'Error requesting payout: $error';
  }

  Future<Result<List<Payout>>> fetchPayoutsByPT(String ptId) async {
    try {
      final response = await _supabaseClient
          .from('payouts')
          .select()
          .eq('pt_id', ptId)
          .order('requested_at', ascending: false);

      final payouts = response.map((e) => Payout.fromMap(e)).toList();

      return Result.success(payouts);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching payouts: $e', code: 500),
      );
    }
  }

  Future<Result<int>> fetchMinPayoutAmount() async {
    try {
      final response = await _supabaseClient
          .from('platform_settings')
          .select('value')
          .eq('key', 'payout_min_amount_cents')
          .maybeSingle();

      if (response == null || response['value'] == null) {
        return Result.success(50000); // Default 50,000 VND
      }

      final value = response['value'] as Map<String, dynamic>;
      return Result.success(value['min_amount'] as int? ?? 50000);
    } catch (e) {
      return Result.success(50000); // Default on error
    }
  }

  Future<Result<void>> updatePayoutStatus(
    String payoutId,
    PayoutStatus newStatus, {
    String? failureReason,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': newStatus.dbValue};

      if (newStatus == PayoutStatus.processing ||
          newStatus == PayoutStatus.completed) {
        updateData['processed_at'] = DateTime.now().toIso8601String();
      }

      if (failureReason != null) {
        updateData['failure_reason'] = failureReason;
      }

      await _supabaseClient
          .from('payouts')
          .update(updateData)
          .eq('id', payoutId);

      // The DB trigger releases linked pt_earnings when the new status is
      // failed or cancelled, so those earnings become available again.
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error updating payout status: $e', code: 500),
      );
    }
  }
}
