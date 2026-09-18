import 'package:flutter/widgets.dart';
import 'package:ontrain/controller/authControlller.dart';
import 'package:ontrain/data/object/payment.dart';
import 'package:ontrain/model/stateEnum.dart';
import 'package:ontrain/repo/paymentRepository.dart';

class Paymentcontroller extends ChangeNotifier {
  final PaymentRepository repository;
  final AuthController authController;

  Paymentcontroller({
    required this.repository,
    required this.authController,
  });

  List<Payment> _payments = [];
  List<Payment> get payments => _payments;

  Payment? _paymentForBooking;
  Payment? get paymentForBooking => _paymentForBooking;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _error;
  String? get error => _error;

  Future<Payment?> fetchPaymentForBooking(String bookingId) async {
    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    final result = await repository.fetchPaymentByBooking(bookingId);
    if (result.isSuccess) {
      _paymentForBooking = result.data;
      _state = ViewState.success;
    } else {
      _paymentForBooking = null;
      _error = result.error?.message;
      _state = ViewState.error;
    }
    notifyListeners();
    return _paymentForBooking;
  }

  Future<List<Payment>> fetchClientPayments() async {
    final clientId = authController.user?.id;
    if (clientId == null) {
      _error = 'User not authenticated';
      _state = ViewState.error;
      notifyListeners();
      return [];
    }

    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    final result = await repository.fetchPaymentsByClient(clientId);
    if (result.isSuccess) {
      _payments = result.data ?? [];
      _state = ViewState.success;
    } else {
      _payments = [];
      _error = result.error?.message;
      _state = ViewState.error;
    }
    notifyListeners();
    return _payments;
  }

  Future<bool> createPaymentForBooking({
    required String bookingId,
    required int amountCents,
    required int platformCommissionCents,
    required int ptAmountCents,
    String paymentMethod = 'stripe',
  }) async {
    final clientId = authController.user?.id;
    if (clientId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _state = ViewState.loading;
    _error = null;
    notifyListeners();

    final payment = Payment(
      bookingId: bookingId,
      clientId: clientId,
      amountCents: amountCents,
      platformCommissionCents: platformCommissionCents,
      ptAmountCents: ptAmountCents,
      paymentMethod: paymentMethod,
      status: PaymentStatus.held,
      externalPaymentId: 'simulated_pi_${DateTime.now().millisecondsSinceEpoch}',
    );

    final result = await repository.createPayment(payment);
    if (result.isSuccess) {
      _state = ViewState.success;
      _payments = [result.data!, ..._payments];
      notifyListeners();
      return true;
    } else {
      _state = ViewState.error;
      _error = result.error?.message;
      notifyListeners();
      return false;
    }
  }
}