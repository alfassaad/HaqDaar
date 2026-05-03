import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/core/providers/app_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<AppProvider>().transactions;
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withAlpha(50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Transactions Yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Your financial activity and aid distribution logs will appear here.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                          ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tx.isCredit ? Colors.green[100] : Colors.red[100],
                      child: Icon(
                        tx.icon,
                        color: tx.isCredit ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(tx.title),
                    subtitle: Text(dateFormatter.format(tx.date)),
                    trailing: Text(
                      '${tx.isCredit ? '+' : '-'} Rs. ${tx.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: tx.isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
