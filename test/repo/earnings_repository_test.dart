import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ontrain/repo/earningsRepository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_utils/fake_supabase.dart';
import '../test_utils/mock_supabase.mocks.dart';

({
  EarningsRepository repository,
  MockSupabaseClient client,
  FakeSupabaseQueryBuilder query,
  FakePostgrestFilterBuilder<PostgrestList> filter,
})
_buildRepository(List<Map<String, dynamic>> rows) {
  final client = MockSupabaseClient();
  final filter = FakePostgrestFilterBuilder<PostgrestList>(rows);
  final query = FakeSupabaseQueryBuilder(filter);
  when(client.from('pt_earnings')).thenAnswer((_) => query);

  return (
    repository: EarningsRepository(supabaseClient: client),
    client: client,
    query: query,
    filter: filter,
  );
}

void main() {
  test(
    'fetchAvailableEarnings filters released, unlinked rows and sums them',
    () async {
      final built = _buildRepository([
        {
          'pt_id': 'pt-1',
          'net_amount_cents': 25000,
          'is_released': true,
          'payout_id': null,
        },
        {
          'pt_id': 'pt-1',
          'net_amount_cents': 35000,
          'is_released': true,
          'payout_id': null,
        },
        {
          'pt_id': 'pt-1',
          'net_amount_cents': 90000,
          'is_released': false,
          'payout_id': null,
        },
        {
          'pt_id': 'pt-1',
          'net_amount_cents': 80000,
          'is_released': true,
          'payout_id': 'payout-9',
        },
        {
          'pt_id': 'pt-2',
          'net_amount_cents': 70000,
          'is_released': true,
          'payout_id': null,
        },
      ]);

      final result = await built.repository.fetchAvailableEarnings('pt-1');

      expect(result.isSuccess, isTrue);
      expect(result.data, 60000);
      expect(built.query.selectedColumns, ['net_amount_cents']);
      expect(built.filter.callsTo(#eq), [
        ['pt_id', 'pt-1'],
        ['is_released', true],
      ]);
      expect(built.filter.callsTo(#isFilter), [
        ['payout_id', null],
      ]);
      expect(built.filter.callsTo(#not), isEmpty);
      verify(built.client.from('pt_earnings')).called(1);
    },
  );

  test('fetchPendingEarnings only filters unreleased rows', () async {
    final built = _buildRepository([
      {
        'pt_id': 'pt-1',
        'net_amount_cents': 10000,
        'is_released': false,
        'payout_id': null,
      },
      {
        'pt_id': 'pt-1',
        'net_amount_cents': 5000,
        'is_released': false,
        'payout_id': null,
      },
      {
        'pt_id': 'pt-1',
        'net_amount_cents': 40000,
        'is_released': true,
        'payout_id': null,
      },
      {
        'pt_id': 'pt-2',
        'net_amount_cents': 30000,
        'is_released': false,
        'payout_id': null,
      },
    ]);

    final result = await built.repository.fetchPendingEarnings('pt-1');

    expect(result.isSuccess, isTrue);
    expect(result.data, 15000);
    expect(built.filter.callsTo(#eq), [
      ['pt_id', 'pt-1'],
      ['is_released', false],
    ]);
    expect(built.filter.callsTo(#isFilter), isEmpty);
    expect(built.filter.callsTo(#not), isEmpty);
  });

  test('fetchPaidOutEarnings filters released rows with a payout id', () async {
    final built = _buildRepository([
      {
        'pt_id': 'pt-1',
        'net_amount_cents': 60000,
        'is_released': true,
        'payout_id': 'payout-1',
      },
      {
        'pt_id': 'pt-1',
        'net_amount_cents': 45000,
        'is_released': true,
        'payout_id': null,
      },
      {
        'pt_id': 'pt-1',
        'net_amount_cents': 30000,
        'is_released': false,
        'payout_id': 'payout-2',
      },
      {
        'pt_id': 'pt-2',
        'net_amount_cents': 20000,
        'is_released': true,
        'payout_id': 'payout-3',
      },
    ]);

    final result = await built.repository.fetchPaidOutEarnings('pt-1');

    expect(result.isSuccess, isTrue);
    expect(result.data, 60000);
    expect(built.filter.callsTo(#eq), [
      ['pt_id', 'pt-1'],
      ['is_released', true],
    ]);
    expect(built.filter.callsTo(#not), [
      ['payout_id', 'is', null],
    ]);
    expect(built.filter.callsTo(#isFilter), isEmpty);
  });

  test(
    'fetchAvailableEarnings returns a failure when the query fails',
    () async {
      final client = MockSupabaseClient();
      final filter = FakePostgrestFilterBuilder<PostgrestList>.error(
        Exception('network down'),
      );
      final query = FakeSupabaseQueryBuilder(filter);
      when(client.from('pt_earnings')).thenAnswer((_) => query);
      final repository = EarningsRepository(supabaseClient: client);

      final result = await repository.fetchAvailableEarnings('pt-1');

      expect(result.isError, isTrue);
      expect(result.error!.message, contains('network down'));
    },
  );
}
