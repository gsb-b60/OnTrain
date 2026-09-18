enum PaymentStatus {
  pending,
  held,
  released,
  refunded,
  failed,
  disputed;

  String get dbValue {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.held:
        return 'held';
      case PaymentStatus.released:
        return 'released';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.disputed:
        return 'disputed';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'held':
        return PaymentStatus.held;
      case 'released':
        return PaymentStatus.released;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'failed':
        return PaymentStatus.failed;
      case 'disputed':
        return PaymentStatus.disputed;
      default:
        return PaymentStatus.pending;
    }
  }
}