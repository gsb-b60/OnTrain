import 'package:flutter/material.dart';
import 'package:ontrain/controller/reviewController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:provider/provider.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({
    super.key,
    required this.bookingId,
    required this.ptId,
    this.ptName = 'Personal Trainer',
  });

  final String bookingId;
  final String ptId;
  final String ptName;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final reviewController = context.read<ReviewController>();
    final success = await reviewController.submitReview(
      bookingId: widget.bookingId,
      ptId: widget.ptId,
      rating: _selectedRating,
      comment: _commentController.text.trim().isNotEmpty
          ? _commentController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (success) {
      _showThankYouDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reviewController.error ?? 'Failed to submit review'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isSubmitting = false);
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Thank You!'),
        content: const Text('Your review has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return true to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                    'Review',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Review Your Personal Trainer',
                    style: TextStyle(
                      color: AppColors.aquaTeal,
                      fontSize: AppSizes.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    backgroundImage: const AssetImage(
                      'assets/PXL_20251014_011048644~2.jpg',
                    ),
                    radius: 65,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.ptName,
                    style: TextStyle(
                      color: AppColors.aquaTeal,
                      fontSize: AppSizes.medium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'IFBBQ',
                    style: TextStyle(color: AppColors.gray700),
                  ),
                  const SizedBox(height: 24),
                  _RatingSelector(
                    selectedRating: _selectedRating,
                    onChanged: (rating) => setState(() => _selectedRating = rating),
                  ),
                  const SizedBox(height: 24),
                  _CommentField(controller: _commentController),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || _selectedRating == 0 ? null : _submitReview,
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
                              'Submit Review',
                              style: TextStyle(
                                color: AppColors.light,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({
    required this.selectedRating,
    required this.onChanged,
  });

  final int selectedRating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.aquaTeal),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (index) => GestureDetector(
            onTap: () => onChanged(index + 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                index < selectedRating ? Icons.star : Icons.star_border,
                color: AppColors.aquaTeal,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommentField extends StatelessWidget {
  const _CommentField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Write your review here (optional)...',
          filled: true,
          fillColor: AppColors.greyAqua,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}