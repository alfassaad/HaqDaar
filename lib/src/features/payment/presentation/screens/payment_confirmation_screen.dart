import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/core/providers/app_provider.dart';
import 'package:myapp/src/core/models/user_model.dart';
import 'package:go_router/go_router.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final String merchantId;
  const PaymentConfirmationScreen({super.key, required this.merchantId});

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isAmountValid = false;
  String _recipientName = 'Loading...';
  UserRole? _recipientRole;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateAmount);
    _lookupRecipient();
  }

  Future<void> _lookupRecipient() async {
    final receiverId = widget.merchantId;
    if (receiverId.isEmpty) return;
    final cleanReceiverId = receiverId.replaceFirst('haqdaar_', '');
    
    final appProvider = context.read<AppProvider>();
    final user = await appProvider.getUser(cleanReceiverId);
    
    if (mounted) {
      setState(() {
        _recipientName = user?.name ?? 'Unknown User';
        _recipientRole = user?.role;
      });
    }
  }

  void _validateAmount() {
    final amount = double.tryParse(_amountController.text);
    setState(() {
      _isAmountValid = amount != null && amount > 0;
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_validateAmount);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handlePayment(BuildContext context) async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final appProvider = context.read<AppProvider>();
    if (amount > appProvider.user.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final receiverId = widget.merchantId;
    if (receiverId.isEmpty) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Merchant ID')),
      );
      return;
    }
    final cleanReceiverId = receiverId.replaceFirst('haqdaar_', '');

    final success = await appProvider.sendMoney(
      receiverId: cleanReceiverId,
      amount: amount,
    );

    if (!context.mounted) return;
    Navigator.pop(context); // Close loading

    if (success) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Rs. $amount sent to $_recipientName',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _recipientRole == UserRole.merchant ? Icons.store : Icons.person,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _recipientName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (_recipientRole != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _recipientRole!.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'ID: ${widget.merchantId.isEmpty ? 'Unknown' : widget.merchantId}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (Rs.)',
                border: OutlineInputBorder(),
                prefixText: 'Rs. ',
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isAmountValid ? () => _handlePayment(context) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Confirm & Pay'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
