import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  void _showHelpDetail(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              _getHelpContent(title),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getHelpContent(String title) {
    switch (title) {
      case 'How to send money?':
        return 'To send money, tap the "Send" button on the home screen, scan the recipient\'s QR code or enter their ID, specify the amount, and confirm with your passcode.';
      case 'How to receive money?':
        return 'To receive money, show your personal QR code to the sender. You can find your QR code by tapping the QR icon in the center of the navigation bar.';
      case 'Security Tips':
        return 'Never share your 4-digit passcode with anyone. HaqDaar employees will never ask for your PIN. Enable biometric login for an extra layer of security.';
      case 'Contact Support':
        return 'Our support team is available 24/7. You can email us at support@haqdaar.app or call our helpline at 111-HAQ-DAAR (427-322).';
      default:
        return 'Details for this topic will be updated soon.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView(
        children: [
          _buildHelpTile(context, 'How to send money?'),
          _buildHelpTile(context, 'How to receive money?'),
          _buildHelpTile(context, 'Security Tips'),
          _buildHelpTile(context, 'Contact Support'),
        ],
      ),
    );
  }

  Widget _buildHelpTile(BuildContext context, String title) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showHelpDetail(context, title),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Last updated: April 2026', style: theme.textTheme.bodySmall),
            const SizedBox(height: 24),
            _section(theme, '1. Introduction', 'HaqDaar ("we", "us", or "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.'),
            _section(theme, '2. Information Collection', 'We collect information that you provide directly to us, including your Name, Phone Number, and CNIC (Computerized National Identity Card) for mandatory identity verification and security purposes.'),
            _section(theme, '3. Data Security', 'We implement state-of-the-art encryption and security measures to protect your personal and financial data. Your CNIC and biometric data are handled with the highest level of security standards.'),
            _section(theme, '4. Use of Information', 'Your data is used solely to facilitate secure peer-to-peer financial aid distribution, prevent fraud, and comply with regulatory requirements.'),
            _section(theme, '5. Sharing of Information', 'We do not sell or rent your personal information to third parties. We may only share information with government authorities if required by law.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _section(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About HaqDaar')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.account_balance_wallet, size: 80, color: Color(0xFF006A4E)),
            const SizedBox(height: 16),
            Text(
              'HaqDaar',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Text('v1.0.0 (Stable Build)'),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'Empowering Transparent Aid Distribution',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'HaqDaar is a cutting-edge digital funding platform designed to revolutionize how financial aid reaches those in need. By leveraging QR technology and secure blockchain-inspired verification, we ensure that every rupee is delivered transparently and securely.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Our Mission',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To bridge the gap between donors and recipients through technology, eliminating intermediaries and ensuring dignity in aid distribution.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            const Text('Made with ❤️ in Pakistan', style: TextStyle(fontWeight: FontWeight.w500)),
            const Text('© 2026 HaqDaar Inc.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
