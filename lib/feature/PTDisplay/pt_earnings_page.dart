import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrain/controller/ptEarningsController.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/core/constrants/app_size.dart';
import 'package:ontrain/data/object/payout.dart';
import 'package:ontrain/data/object/pt_earnings.dart';
import 'package:ontrain/data/enum/earningsStatus.dart';
import 'package:ontrain/data/enum/payoutStatus.dart';
import 'package:ontrain/model/stateEnum.dart';
import 'package:provider/provider.dart';

class PTEarningsPage extends StatefulWidget {
  const PTEarningsPage({super.key});

  @override
  State<PTEarningsPage> createState() => _PTEarningsPageState();
}

class _PTEarningsPageState extends State<PTEarningsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PTEarningsController>().fetchEarningsSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PTEarningsController>(
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
                    controller.error ?? 'Error loading earnings',
                    style: TextStyle(color: AppColors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchEarningsSummary(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchEarningsSummary(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.aquaTeal,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsetsDirectional.only(
                      start: 20,
                      bottom: 16,
                    ),
                    title: const Text(
                      'Earnings',
                      style: TextStyle(
                        color: AppColors.light,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppGradients.brand,
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 56),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BalanceCard(
                            label: 'Available Balance',
                            amount: controller.availableBalance,
                            color: AppColors.aquaTeal,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _BalanceCard(
                                  label: 'Pending',
                                  amount: controller.pendingBalance,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _BalanceCard(
                                  label: 'Paid Out',
                                  amount: controller.paidOutBalance,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    if (controller.availableBalance >=
                        controller.minPayoutAmount)
                      IconButton(
                        icon: const Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.light,
                        ),
                        onPressed: () => _showPayoutDialog(context, controller),
                        tooltip: 'Request Payout',
                      ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.availableBalance <
                            controller.minPayoutAmount)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Minimum payout: ${NumberFormat('#,###').format(controller.minPayoutAmount)} VND. '
                                    'Your available balance: ${NumberFormat('#,###').format(controller.availableBalance)} VND',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _SectionHeader(
                          title: 'Earnings History',
                          count: controller.earningsHistory.length,
                        ),
                        if (controller.earningsHistory.isEmpty)
                          _EmptyState(message: 'No earnings yet')
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.earningsHistory.length,
                            itemBuilder: (context, index) {
                              final earning = controller.earningsHistory[index];
                              return _EarningsTile(earning: earning);
                            },
                          ),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: 'Payout History',
                          count: controller.payoutHistory.length,
                        ),
                        if (controller.payoutHistory.isEmpty)
                          _EmptyState(message: 'No payouts requested yet')
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.payoutHistory.length,
                            itemBuilder: (context, index) {
                              final payout = controller.payoutHistory[index];
                              return _PayoutTile(payout: payout);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPayoutDialog(
    BuildContext context,
    PTEarningsController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Payout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available: ${NumberFormat('#,###').format(controller.availableBalance)} VND',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Min: ${NumberFormat('#,###').format(controller.minPayoutAmount)} VND',
              style: TextStyle(color: AppColors.gray700),
            ),
            const SizedBox(height: 16),
            const Text(
              'The full available balance will be requested and paid to the '
              'bank account saved in your PT profile.',
            ),
            if (controller.error != null && controller.state == ViewState.error)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.requestPayout();
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${NumberFormat('#,###').format(amount)} VND',
            style: TextStyle(
              color: color,
              fontSize: AppSizes.semiLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.aquaTeal,
              fontSize: AppSizes.medium,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.aquaTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.aquaTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: AppColors.gray500, fontSize: 16),
        ),
      ),
    );
  }
}

class _EarningsTile extends StatelessWidget {
  const _EarningsTile({required this.earning});

  final PTEarnings earning;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _EarningsStatusIcon(status: earning.status),
        title: Text(
          'Booking: ${earning.bookingId.substring(0, 8)}...',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Gross: ${NumberFormat('#,###').format(earning.amountCents)} VND',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Net: ${NumberFormat('#,###').format(earning.netAmountCents)} VND',
              style: TextStyle(
                color: AppColors.aquaTeal,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (earning.createdAt != null)
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(earning.createdAt!),
                style: TextStyle(color: AppColors.gray500, fontSize: 11),
              ),
          ],
        ),
        trailing: _EarningsStatusChip(status: earning.status),
      ),
    );
  }
}

class _EarningsStatusIcon extends StatelessWidget {
  const _EarningsStatusIcon({required this.status});

  final EarningsStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case EarningsStatus.released:
        color = AppColors.aquaTeal;
        icon = Icons.check_circle;
        break;
      case EarningsStatus.paidOut:
        color = Colors.green;
        icon = Icons.account_balance_wallet;
        break;
      case EarningsStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _EarningsStatusChip extends StatelessWidget {
  const _EarningsStatusChip({required this.status});

  final EarningsStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case EarningsStatus.released:
        color = AppColors.aquaTeal;
        label = 'Released';
        break;
      case EarningsStatus.paidOut:
        color = Colors.green;
        label = 'Paid Out';
        break;
      case EarningsStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
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

class _PayoutTile extends StatelessWidget {
  const _PayoutTile({required this.payout});

  final Payout payout;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _PayoutStatusIcon(status: payout.status),
        title: Text(
          '${NumberFormat('#,###').format(payout.amountCents)} VND',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(payout.bankName, style: const TextStyle(fontSize: 12)),
            if (payout.requestedAt != null)
              Text(
                'Requested: ${DateFormat('dd/MM/yyyy HH:mm').format(payout.requestedAt!)}',
                style: TextStyle(color: AppColors.gray500, fontSize: 11),
              ),
            if (payout.processedAt != null)
              Text(
                'Processed: ${DateFormat('dd/MM/yyyy HH:mm').format(payout.processedAt!)}',
                style: TextStyle(color: AppColors.aquaTeal, fontSize: 11),
              ),
            if (payout.failureReason != null)
              Text(
                'Failed: ${payout.failureReason}',
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
          ],
        ),
        trailing: _PayoutStatusChip(status: payout.status),
      ),
    );
  }
}

class _PayoutStatusIcon extends StatelessWidget {
  const _PayoutStatusIcon({required this.status});

  final PayoutStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case PayoutStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case PayoutStatus.processing:
        color = Colors.blue;
        icon = Icons.sync;
        break;
      case PayoutStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case PayoutStatus.failed:
        color = Colors.red;
        icon = Icons.error;
        break;
      case PayoutStatus.cancelled:
        color = Colors.grey;
        icon = Icons.cancel;
        break;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _PayoutStatusChip extends StatelessWidget {
  const _PayoutStatusChip({required this.status});

  final PayoutStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case PayoutStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case PayoutStatus.processing:
        color = Colors.blue;
        label = 'Processing';
        break;
      case PayoutStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case PayoutStatus.failed:
        color = Colors.red;
        label = 'Failed';
        break;
      case PayoutStatus.cancelled:
        color = Colors.grey;
        label = 'Cancelled';
        break;
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
