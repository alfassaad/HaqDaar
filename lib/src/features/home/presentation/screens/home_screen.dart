import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          Text(
            'John Doe',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, size: 28),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FeatureIcon(
          icon: Icons.qr_code_scanner,
          label: 'Scan & Pay',
          onTap: () => context.go('/scan-and-pay'),
        ),
        FeatureIcon(
          icon: Icons.qr_code,
          label: 'My QR',
          onTap: () => context.go('/qr'),
        ),
        const FeatureIcon(icon: Icons.send, label: 'Send'),
        const FeatureIcon(icon: Icons.receipt, label: 'Recieve'),
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
    // Mock data
    final transactions = [
      {
        'name': 'Haji Super Store',
        'date': '2024-07-26',
        'amount': '- Rs. 1,200',
        'icon': Icons.store,
      },
      {
        'name': 'Haris Store',
        'date': '2024-07-25',
        'amount': '- Rs. 550',
        'icon': Icons.store,
      },
      {
        'name': 'Zahid Ali',
        'date': '2024-07-24',
        'amount': '+ Rs. 3,000',
        'icon': Icons.person,
      },
    ];

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isCredit = (transaction['amount'] as String).startsWith('+');

        return ListTile(
          leading: Icon(transaction['icon'] as IconData, size: 32),
          title: Text(transaction['name'] as String),
          subtitle: Text(transaction['date'] as String),
          trailing: Text(
            transaction['amount'] as String,
            style: TextStyle(
              color: isCredit ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
