import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> transactions = [
      {'name': 'Haji Ali Juice Center', 'amount': '- ₹250', 'date': '2024-07-20'},
      {'name': 'Received from John Doe', 'amount': '+ ₹1000', 'date': '2024-07-19'},
      {'name': 'Elco Restaurant', 'amount': '- ₹800', 'date': '2024-07-18'},
      {'name': 'Candies', 'amount': '- ₹500', 'date': '2024-07-17'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final isCredit = transaction['amount']!.startsWith('+');

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              title: Text(transaction['name']!),
              subtitle: Text(transaction['date']!),
              trailing: Text(
                transaction['amount']!,
                style: TextStyle(
                  color: isCredit ? Colors.green : Colors.red,
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
