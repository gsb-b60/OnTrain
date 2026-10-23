import 'package:ontrain/data/object/pt_earnings.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EarningsRepository {
  final SupabaseClient _supabaseClient;

  EarningsRepository({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  Future<Result<List<PTEarnings>>> fetchEarningsByPT(String ptId) async {
    try {
      final response = await _supabaseClient
          .from('pt_earnings')
          .select()
          .eq('pt_id', ptId)
          .order('created_at', ascending: false);

      final earnings = response.map((e) => PTEarnings.fromMap(e)).toList();

      return Result.success(earnings);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching earnings: $e', code: 500),
      );
    }
  }

  Future<Result<int>> fetchAvailableEarnings(String ptId) async {
    try {
      final response = await _supabaseClient
          .from('pt_earnings')
          .select('net_amount_cents')
          .eq('pt_id', ptId)
          .eq('is_released', true)
          .isFilter('payout_id', null);

      final sum = response.fold<int>(
        0,
        (total, row) => total + (row['net_amount_cents'] as int? ?? 0),
      );

      return Result.success(sum);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching available earnings: $e', code: 500),
      );
    }
  }

  Future<Result<List<PTEarnings>>> fetchEarningsHistory(String ptId) async {
    return fetchEarningsByPT(ptId);
  }

  Future<Result<int>> fetchPendingEarnings(String ptId) async {
    try {
      final response = await _supabaseClient
          .from('pt_earnings')
          .select('net_amount_cents')
          .eq('pt_id', ptId)
          .eq('is_released', false);

      final sum = response.fold<int>(
        0,
        (total, row) => total + (row['net_amount_cents'] as int? ?? 0),
      );

      return Result.success(sum);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching pending earnings: $e', code: 500),
      );
    }
  }

  Future<Result<int>> fetchPaidOutEarnings(String ptId) async {
    try {
      final response = await _supabaseClient
          .from('pt_earnings')
          .select('net_amount_cents')
          .eq('pt_id', ptId)
          .eq('is_released', true)
          .not('payout_id', 'is', null);

      final sum = response.fold<int>(
        0,
        (total, row) => total + (row['net_amount_cents'] as int? ?? 0),
      );

      return Result.success(sum);
    } catch (e) {
      return Result.failure(
        RepoError(message: 'Error fetching paid out earnings: $e', code: 500),
      );
    }
  }
}
