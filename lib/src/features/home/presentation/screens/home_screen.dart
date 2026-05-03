import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/core/providers/app_provider.dart';
import 'package:myapp/src/core/models/transaction_model.dart' as models;
import 'package:myapp/src/features/home/presentation/widgets/notification_popup.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BalanceCard(),
                const SizedBox(height: 24),
                Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const FeatureGrid(),
                const SizedBox(height: 24),
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Expanded(
                  child: TransactionList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = context.select((AppProvider p) => p.user.balance);
    final formatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(balance),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  OverlayEntry? _overlayEntry;

  void _showNotificationPopup(BuildContext context, List<models.Transaction> transactions) {
    if (_overlayEntry != null) {
      _hideNotificationPopup();
      return;
    }

    // Capture the overlay state before creating the builder
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => NotificationPopup(
        notifications: transactions,
        onClose: () {
          _hideNotificationPopup();
          // Clear notifications when popup is closed or "marked as read"
          // Using the original context to avoid issues with the overlay context
          Provider.of<AppProvider>(context, listen: false).clearNotifications();
        },
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideNotificationPopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideNotificationPopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              Text(
                appProvider.user.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          );
        },
      ),
      actions: [
        Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            return Stack(
              children: [
                IconButton(
                  icon: Icon(
                    appProvider.hasNewNotification ? Icons.notifications_active : Icons.notifications_none,
                    size: 28,
                    color: appProvider.hasNewNotification ? Colors.red : null,
                  ),
                  onPressed: () => _showNotificationPopup(context, appProvider.transactions),
                ),
                if (appProvider.hasNewNotification)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FeatureIcon(
          icon: Icons.qr_code_scanner,
          label: user.isMerchant ? 'Accept' : 'Scan & Pay',
          onTap: () => context.go('/scan-and-pay'),
        ),
        FeatureIcon(
          icon: Icons.qr_code,
          label: 'My QR',
          onTap: () => context.go('/qr'),
        ),
        if (user.canDisburse)
          FeatureIcon(
            icon: Icons.volunteer_activism,
            label: 'Disburse',
            onTap: () => context.go('/scan-and-pay'),
          )
        else if (user.canSendP2P)
          FeatureIcon(
            icon: Icons.send,
            label: 'Send',
            onTap: () => context.go('/scan-and-pay'),
          ),
        if (user.canClaimAid)
          FeatureIcon(
            icon: Icons.volunteer_activism,
            label: 'Claim Aid',
            onTap: () => context.go('/qr'),
          )
        else if (!user.isMerchant)
          FeatureIcon(
            icon: Icons.receipt,
            label: 'Receive',
            onTap: () => context.go('/qr'),
          ),
      ],
    );
  }
}

class FeatureIcon extends StatelessWidget {
  const FeatureIcon({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<AppProvider>().transactions;
    final formatter = DateFormat('yyyy-MM-dd');

    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions yet'));
    }

    return ListView.builder(
      itemCount: transactions.length > 5 ? 5 : transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: tx.isCredit ? Colors.green[50] : Colors.red[50],
            child: Icon(tx.icon, size: 24, color: tx.isCredit ? Colors.green : Colors.red),
          ),
          title: Text(tx.title),
          subtitle: Text(formatter.format(tx.date)),
          trailing: Text(
            '${tx.isCredit ? '+' : '-'} Rs. ${tx.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: tx.isCredit ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
