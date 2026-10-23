import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/data/object/payout.dart';
import 'package:ontrain/data/object/pt_earnings.dart';
import 'package:ontrain/model/stateEnum.dart';
import 'package:ontrain/repo/earningsRepository.dart';
import 'package:ontrain/repo/payoutRepository.dart';

class PTEarningsController extends ChangeNotifier {
  final EarningsRepository earningsRepository;
  final PayoutRepository payoutRepository;
  final AuthController authController;

  PTEarningsController({
    required this.earningsRepository,
    required this.payoutRepository,
    required this.authController,
  });

  int _availableBalance = 0;
  int get availableBalance => _availableBalance;

  int _pendingBalance = 0;
  int get pendingBalance => _pendingBalance;

  int _paidOutBalance = 0;
  int get paidOutBalance => _paidOutBalance;

  List<PTEarnings> _earningsHistory = [];
  List<PTEarnings> get earningsHistory => _earningsHistory;

  List<Payout> _payoutHistory = [];
  List<Payout> get payoutHistory => _payoutHistory;

  int _minPayoutAmount = 50000;
  int get minPayoutAmount => _minPayoutAmount;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _error;
  String? get error => _error;

  Future<void> fetchEarningsSummary() async {
    final ptId = authController.user?.id;
    if (ptId == null) {
      _error = 'PT not authenticated';
      _state = ViewState.error;
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    try {
      final availableResult = await earningsRepository.fetchAvailableEarnings(
        ptId,
      );
      final pendingResult = await earningsRepository.fetchPendingEarnings(ptId);
      final paidOutResult = await earningsRepository.fetchPaidOutEarnings(ptId);
      final historyResult = await earningsRepository.fetchEarningsHistory(ptId);
      final payoutsResult = await payoutRepository.fetchPayoutsByPT(ptId);
      final minAmountResult = await payoutRepository.fetchMinPayoutAmount();

      if (availableResult.isSuccess) {
        _availableBalance = availableResult.data ?? 0;
      }
      if (pendingResult.isSuccess) {
        _pendingBalance = pendingResult.data ?? 0;
      }
      if (paidOutResult.isSuccess) {
        _paidOutBalance = paidOutResult.data ?? 0;
      }
      if (historyResult.isSuccess) {
        _earningsHistory = historyResult.data ?? [];
      }
      if (payoutsResult.isSuccess) {
        _payoutHistory = payoutsResult.data ?? [];
      }
      if (minAmountResult.isSuccess) {
        _minPayoutAmount = minAmountResult.data ?? 50000;
      }

      _state = ViewState.success;
    } catch (e) {
      _error = 'Error fetching earnings: $e';
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> requestPayout() async {
    final ptId = authController.user?.id;
    if (ptId == null) {
      _error = 'PT not authenticated';
      notifyListeners();
      return false;
    }

    if (_availableBalance < _minPayoutAmount) {
      _error =
          'Minimum payout amount is ${NumberFormat('#,###').format(_minPayoutAmount)} VND';
      notifyListeners();
      return false;
    }

    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    final result = await payoutRepository.requestPayout();

    if (result.isSuccess) {
      // Re-read the ledger so the balances and histories reflect the payout.
      await fetchEarningsSummary();
      return true;
    }

    _state = ViewState.error;
    _error = result.error?.message ?? 'Failed to request payout';
    notifyListeners();
    return false;
  }
}
