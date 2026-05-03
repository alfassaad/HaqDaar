import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/core/models/transaction_model.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPopup extends StatelessWidget {
  final List<Transaction> notifications;
  final VoidCallback onClose;

  const NotificationPopup({
    super.key,
    required this.notifications,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('MMM d, h:mm a');

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Invisible tap area to close the popup
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
          ),
          // The actual popup box
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top - 10,
            right: 16,
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 400),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.oswald().fontFamily,
                          ),
                        ),
                        if (notifications.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${notifications.length} New',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (notifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text('No new notifications'),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tx = notifications[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: tx.isCredit ? Colors.green[50] : Colors.red[50],
                              child: Icon(
                                tx.icon,
                                size: 18,
                                color: tx.isCredit ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              tx.title,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              formatter.format(tx.date),
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Text(
                              'Rs. ${tx.amount.toStringAsFixed(0)}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: tx.isCredit ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: TextButton(
                        onPressed: onClose,
                        child: const Text('Mark all as read'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
