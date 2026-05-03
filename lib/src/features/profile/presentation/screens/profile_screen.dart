import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/core/providers/app_provider.dart';
import 'package:myapp/src/core/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<AppProvider>().user;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary.withAlpha(50)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRoleIcon(user.role),
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.role.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile Options
            _buildSection(context, 'Personal Information', [
              _buildTile(context, Icons.person_outline, 'Profile Details', user.name, route: '/profile/edit'),
            ]),

            _buildSection(context, 'Security & Settings', [
              _buildTile(context, Icons.lock_outline, 'Security Settings', 'Passcode & Biometrics', route: '/profile/security'),
              _buildTile(
                context, 
                Icons.notifications_none, 
                'Notifications', 
                'On', 
                isToggle: true,
                toggleValue: context.watch<AppProvider>().isNotificationsEnabled,
                onToggle: (v) => context.read<AppProvider>().toggleNotifications(v),
              ),
            ]),

            _buildSection(context, 'Support', [
              _buildTile(context, Icons.help_outline, 'Help Center', null, route: '/profile/help'),
              _buildTile(context, Icons.policy_outlined, 'Privacy Policy', null, route: '/profile/privacy'),
              _buildTile(context, Icons.info_outline, 'About HaqDaar', null, route: '/profile/about'),
            ]),

            if (user.isAdmin)
              _buildSection(context, 'Administration', [
                _buildTile(context, Icons.admin_panel_settings_outlined, 'Admin Dashboard', 'Manage Users & Roles', route: '/profile/admin'),
              ]),

            const SizedBox(height: 24),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AppProvider>().logout();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout Account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).toInt()),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, 
    IconData icon, 
    String title, 
    String? subtitle, 
    {String? route, bool isToggle = false, bool? toggleValue, ValueChanged<bool>? onToggle}
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: isToggle 
          ? Switch(
              value: toggleValue ?? false, 
              onChanged: onToggle, 
              activeTrackColor: Theme.of(context).colorScheme.primary,
              activeThumbColor: Colors.white,
            )
          : const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: isToggle ? null : () {
        if (route != null) {
          context.push(route);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title details are not available yet.')),
          );
        }
      },
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.recipient:
        return Icons.verified;
      case UserRole.donor:
        return Icons.favorite;
      case UserRole.merchant:
        return Icons.store;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}
