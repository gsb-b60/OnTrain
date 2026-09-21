import 'package:flutter/material.dart';
import 'package:ontrain/controller/bookingController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/dispute.dart';
import 'package:ontrain/data/enum/disputeStatus.dart';
import 'package:provider/provider.dart';

class DisputePage extends StatefulWidget {
  const DisputePage({super.key});

  @override
  State<DisputePage> createState() => _DisputePageState();
}

class _DisputePageState extends State<DisputePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Bookingcontroller>().fetchDisputes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disputes'),
        backgroundColor: AppColors.aquaTeal,
        foregroundColor: AppColors.light,
      ),
      body: Consumer<Bookingcontroller>(
        builder: (context, controller, child) {
          if (controller.state == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.state == ViewState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.error ?? 'Error loading disputes',
                    style: TextStyle(color: AppColors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchDisputes(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final disputes = controller.fetchDisputes(); // This will re-fetch, better to store in controller

          return FutureBuilder<List<Dispute>>(
            future: controller.fetchDisputes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final disputes = snapshot.data ?? [];

              if (disputes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.gavel,
                        size: 64,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No disputes yet',
                        style: TextStyle(
                          color: AppColors.gray700,
                          fontSize: AppSizes.medium,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: disputes.length,
                itemBuilder: (context, index) {
                  final dispute = disputes[index];
                  return _DisputeTile(dispute: dispute);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DisputeTile extends StatelessWidget {
  const _DisputeTile({required this.dispute});

  final Dispute dispute;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: _DisputeStatusIcon(status: dispute.status),
        title: Text(
          'Booking: ${dispute.bookingId.substring(0, 8)}...',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Raised: ${dispute.createdAt != null ? "${dispute.createdAt!.day}/${dispute.createdAt!.month}/${dispute.createdAt!.year}" : 'Unknown'}',
          style: TextStyle(color: AppColors.gray500, fontSize: 12),
        ),
        trailing: _DisputeStatusChip(status: dispute.status),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reason:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(dispute.reason),
                const SizedBox(height: 16),
                if (dispute.resolutionNotes != null) ...[
                  const Text(
                    'Resolution:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(dispute.resolutionNotes!),
                  const SizedBox(height: 16),
                ],
                if (dispute.resolvedAt != null) ...[
                  Text(
                    'Resolved: ${DateFormat('dd/MM/yyyy HH:mm').format(dispute.resolvedAt!)}',
                    style: TextStyle(color: AppColors.gray500, fontSize: 12),
                  ),
                ],
                if (dispute.resolvedBy != null) ...[
                  Text(
                    'Resolved by: ${dispute.resolvedBy}',
                    style: TextStyle(color: AppColors.gray500, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisputeStatusIcon extends StatelessWidget {
  const _DisputeStatusIcon({required this.status});

  final DisputeStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case DisputeStatus.resolvedClient:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case DisputeStatus.resolvedPt:
        color = Colors.blue;
        icon = Icons.check_circle;
        break;
      case DisputeStatus.resolvedSplit:
        color = Colors.purple;
        icon = Icons.check_circle;
        break;
      case DisputeStatus.refunded:
        color = Colors.orange;
        icon = Icons.money_off;
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _DisputeStatusChip extends StatelessWidget {
  const _DisputeStatusChip({required this.status});

  final DisputeStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case DisputeStatus.resolvedClient:
        color = Colors.green;
        label = 'Resolved (Client)';
        break;
      case DisputeStatus.resolvedPt:
        color = Colors.blue;
        label = 'Resolved (PT)';
        break;
      case DisputeStatus.resolvedSplit:
        color = Colors.purple;
        label = 'Resolved (Split)';
        break;
      case DisputeStatus.refunded:
        color = Colors.orange;
        label = 'Refunded';
        break;
      default:
        color = Colors.orange;
        label = 'Open';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}