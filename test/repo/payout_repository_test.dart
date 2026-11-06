import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ontrain/repo/payoutRepository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_utils/fake_supabase.dart';
import '../test_utils/mock_supabase.mocks.dart';

void main() {
  test('requestPayout calls the request_payout RPC', () async {
    final client = MockSupabaseClient();
    when(
      client.rpc<String>('request_payout'),
    ).thenAnswer((_) => FakePostgrestFilterBuilder<String>('payout-1'));
    final repository = PayoutRepository(supabaseClient: client);

    final result = await repository.requestPayout();

    expect(result.isSuccess, isTrue);
    expect(result.data, 'payout-1');
    verify(client.rpc<String>('request_payout')).called(1);
  });

  test('requestPayout maps a database minimum error', () async {
    final client = MockSupabaseClient();
    when(client.rpc<String>('request_payout')).thenAnswer(
      (_) => FakePostgrestFilterBuilder<String>.error(
        PostgrestException(message: 'below minimum payout'),
      ),
    );
    final repository = PayoutRepository(supabaseClient: client);

    final result = await repository.requestPayout();

    expect(result.isError, isTrue);
    expect(
      result.error!.message,
      'Available balance is below the minimum payout',
    );
  });

  test('requestPayout maps a database bank-details error', () async {
    final client = MockSupabaseClient();
    when(client.rpc<String>('request_payout')).thenAnswer(
      (_) => FakePostgrestFilterBuilder<String>.error(
        PostgrestException(message: 'bank details not configured'),
      ),
    );
    final repository = PayoutRepository(supabaseClient: client);

    final result = await repository.requestPayout();

    expect(result.isError, isTrue);
    expect(result.error!.message, 'Bank details not configured in profile');
  });
}
