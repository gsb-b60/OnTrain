import 'package:ontrain/data/object/payout.dart';
import 'package:ontrain/data/enum/payoutStatus.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PayoutRepository {
  final SupabaseClient _supabaseClient;

  PayoutRepository({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<Result<String>> requestPayout({
    required String ptId,
    required int amountCents,
    required String bankAccountName,
    required String bankAccountNumber,
    required String bankName,
    String? bankBranch,
  }) async {
    try {
      final response = await _supabaseClient
          .from('payouts')
          .insert({
            'pt_id': ptId,
            'amount_cents': amountCents,
            'status': 'requested',
            'bank_account_name': bankAccountName,
            'bank_account_number': bankAccountNumber,
            'bank_name': bankName,
            'bank_branch': bankBranch,
          })
          .select('id')
          .single();

      return Result.success(response['id'] as String);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error requesting payout: $e', code: 500),
      );
    }
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
      final updateData = <String, dynamic>{
        'status': newStatus.dbValue,
      };

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

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error updating payout status: $e', code: 500),
      );
    }
  }
}