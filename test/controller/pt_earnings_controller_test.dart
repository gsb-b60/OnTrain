import 'package:flutter_test/flutter_test.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/controller/ptEarningsController.dart';
import 'package:ontrain/data/enum/userRole.dart';
import 'package:ontrain/data/object/payout.dart';
import 'package:ontrain/data/object/pt_earnings.dart';
import 'package:ontrain/data/object/user.dart';
import 'package:ontrain/model/error.dart';
import 'package:ontrain/model/result.dart';
import 'package:ontrain/repo/auth/authRepo.dart';
import 'package:ontrain/repo/earningsRepository.dart';
import 'package:ontrain/repo/payoutRepository.dart';

import '../test_utils/mock_supabase.mocks.dart';

class _FakeAuthrepo extends Authrepo {
  _FakeAuthrepo() : super(supabaseClient: MockSupabaseClient());

  @override
  Future<Result<UserData>> getCurrentUser() async {
    return Result.success(
      UserData(
        id: 'pt-1',
        email: 'pt1@test.com',
        fullName: 'Test PT',
        role: UserRole.pt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }
}

class _FakeEarningsRepository extends EarningsRepository {
  _FakeEarningsRepository({this.available = 0})
    : super(supabaseClient: MockSupabaseClient());

  int available;
  int availableCalls = 0;

  @override
  Future<Result<int>> fetchAvailableEarnings(String ptId) async {
    availableCalls++;
    return Result.success(available);
  }

  @override
  Future<Result<int>> fetchPendingEarnings(String ptId) async {
    return Result.success(0);
  }

  @override
  Future<Result<int>> fetchPaidOutEarnings(String ptId) async {
    return Result.success(0);
  }

  @override
  Future<Result<List<PTEarnings>>> fetchEarningsByPT(String ptId) async {
    return Result.success(const []);
  }

  @override
  Future<Result<List<PTEarnings>>> fetchEarningsHistory(String ptId) async {
    return Result.success(const []);
  }
}

class _FakePayoutRepository extends PayoutRepository {
  _FakePayoutRepository({this.succeeds = true})
    : super(supabaseClient: MockSupabaseClient());

  bool succeeds;
  int requestCalls = 0;

  @override
  Future<Result<String>> requestPayout() async {
    requestCalls++;
    if (!succeeds) {
      return Result.failure(
        RepoError(message: 'No available earnings to withdraw', code: 500),
      );
    }
    return Result.success('payout-1');
  }

  @override
  Future<Result<List<Payout>>> fetchPayoutsByPT(String ptId) async {
    return Result.success(const []);
  }

  @override
  Future<Result<int>> fetchMinPayoutAmount() async {
    return Result.success(50000);
  }
}

Future<PTEarningsController> _buildController({
  required _FakeEarningsRepository earnings,
  required _FakePayoutRepository payouts,
}) async {
  final auth = AuthController(repo: _FakeAuthrepo());
  await auth.getCurrentUserData();

  return PTEarningsController(
    earningsRepository: earnings,
    payoutRepository: payouts,
    authController: auth,
  );
}

void main() {
  test('requestPayout rejects a balance below the minimum', () async {
    final earnings = _FakeEarningsRepository(available: 30000);
    final payouts = _FakePayoutRepository();
    final controller = await _buildController(
      earnings: earnings,
      payouts: payouts,
    );

    await controller.fetchEarningsSummary();
    final result = await controller.requestPayout();

    expect(result, isFalse);
    expect(controller.error, contains('Minimum payout'));
    expect(payouts.requestCalls, 0);
  });

  test('requestPayout refreshes the summary on success', () async {
    final earnings = _FakeEarningsRepository(available: 100000);
    final payouts = _FakePayoutRepository();
    final controller = await _buildController(
      earnings: earnings,
      payouts: payouts,
    );

    await controller.fetchEarningsSummary();
    final result = await controller.requestPayout();

    expect(result, isTrue);
    expect(payouts.requestCalls, 1);
    expect(earnings.availableCalls, 2);
    expect(controller.state.name, 'success');
  });

  test('requestPayout surfaces repository errors', () async {
    final earnings = _FakeEarningsRepository(available: 100000);
    final payouts = _FakePayoutRepository(succeeds: false);
    final controller = await _buildController(
      earnings: earnings,
      payouts: payouts,
    );

    await controller.fetchEarningsSummary();
    final result = await controller.requestPayout();

    expect(result, isFalse);
    expect(controller.error, contains('No available earnings'));
    expect(controller.state.name, 'error');
  });
}
