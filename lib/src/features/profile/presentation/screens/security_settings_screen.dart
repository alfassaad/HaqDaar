import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/core/providers/app_provider.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Passcode'),
            subtitle: Text(appProvider.user.passcode != null ? 'Enabled' : 'Not configured'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              _showChangePasscodeDialog(context, appProvider);
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Login'),
            subtitle: const Text('Use Face ID or Fingerprint'),
            value: appProvider.isBiometricEnabled,
            onChanged: (value) {
              appProvider.toggleBiometric(value);
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasscodeDialog(BuildContext context, AppProvider appProvider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Passcode'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: 'Enter New 4-Digit Passcode',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) {
                appProvider.setPasscode(controller.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passcode updated successfully')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
