import 'package:flutter/material.dart';
import 'package:ontrain/controller/bookingController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/enum/cancelReason.dart';
import 'package:provider/provider.dart';

class CancelAppoint extends StatefulWidget {
  const CancelAppoint({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<CancelAppoint> createState() => _CancelAppointState();
}

class _CancelAppointState extends State<CancelAppoint> {
  CancelReason? _selectedReason;
  final _customReasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  Future<void> _handleCancel() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final bookingController = context.read<Bookingcontroller>();
    final (success, feeCents, refundCents) = await bookingController.cancelBooking(
      bookingId: widget.bookingId,
      uiReason: _selectedReason!,
      customReason: _customReasonController.text.trim().isNotEmpty
          ? _customReasonController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (success) {
      final feeText = feeCents > 0
          ? 'Fee: ${feeCents ~/ 100}.${(feeCents % 100).toString().padLeft(2, '0')} VND'
          : 'No fee';
      final refundText = refundCents > 0
          ? 'Refund: ${refundCents ~/ 100}.${(refundCents % 100).toString().padLeft(2, '0')} VND'
          : 'No refund';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking cancelled. $feeText. $refundText'),
          backgroundColor: AppColors.aquaTeal,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingController.error ?? 'Cancellation failed'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.aquaTeal),
              width: double.infinity,
              height: 75,
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'Cancel appointment',
                      style: TextStyle(
                        color: AppColors.light,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.light),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to cancel this appointment?',
                    style: TextStyle(
                      fontSize: AppSizes.medium,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _ReasonSelector(
                    selectedReason: _selectedReason,
                    onChanged: (reason) => setState(() => _selectedReason = reason),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'It is ok to cancel if you announce soon enough',
                    style: TextStyle(color: AppColors.aquaTeal),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _customReasonController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Enter additional reason (optional)...',
                        filled: true,
                        fillColor: AppColors.greyAqua,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FeePreviewCard(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.aquaTeal,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(AppColors.light),
                              ),
                            )
                          : const Text(
                              'Cancel Appointment',
                              style: TextStyle(
                                color: AppColors.light,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonSelector extends StatelessWidget {
  const _ReasonSelector({
    required this.selectedReason,
    required this.onChanged,
  });

  final CancelReason? selectedReason;
  final ValueChanged<CancelReason?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: CancelReason.values.map((reason) {
        return RadioListTile<CancelReason>(
          title: Text(reason.displayName),
          value: reason,
          groupValue: selectedReason,
          onChanged: onChanged,
          activeColor: AppColors.aquaTeal,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        );
      }).toList(),
    );
  }
}

class _FeePreviewCard extends StatelessWidget {
  const _FeePreviewCard();

  @override
  Widget build(BuildContext context) {
    // In a real implementation, this would show calculated fee based on
    // booking time and policy. For now, show policy info.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.aquaTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.aquaTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.aquaTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cancellation Policy',
                style: TextStyle(
                  color: AppColors.aquaTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Free cancellation: > 24 hours before session\n'
            '• Late cancellation (≤ 24h): 50% fee\n'
            '• No-show: 100% fee (no refund)\n'
            '• Admin cancellation: No fee',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}