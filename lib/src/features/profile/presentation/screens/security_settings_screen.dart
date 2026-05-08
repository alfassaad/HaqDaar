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
               if (controller.text.length == 4 && controller.text.isNotEmpty && RegExp(r'^\d+$').hasMatch(controller.text)) {
                 // Check for weak passcodes
                 final weakPasscodes = ['0000', '1111', '2222', '3333', '4444', '5555', '6666', '7777', '8888', '9999', '1234', '4321'];
                 if (weakPasscodes.contains(controller.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please use a stronger passcode'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                   return;
                 }
                 
                 appProvider.setPasscode(controller.text);
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Passcode updated successfully')),
                 );
                 Navigator.pop(context);
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                      content: const Text('Passcode must be 4 digits'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
             },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
