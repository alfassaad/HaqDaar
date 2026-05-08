import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/core/providers/app_provider.dart';
import 'package:myapp/src/core/models/user_model.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final users = appProvider.allUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => _showUserDialog(context, appProvider),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(user.name.substring(0, 1).toUpperCase()),
              ),
              title: Text(user.name),
              subtitle: Text('Role: ${user.role.displayName}\nCNIC: ${user.cnic ?? "Not set"}\nUID: ${user.id}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: Colors.blue),
                    onPressed: () => _showUserDialog(context, appProvider, user: user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirm(context, appProvider, user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUserDialog(BuildContext context, AppProvider appProvider, {UserProfile? user}) {
    final nameController = TextEditingController(text: user?.name);
    final cnicController = TextEditingController(text: user?.cnic);
    final idController = TextEditingController(text: user?.id);
    UserRole selectedRole = user?.role ?? UserRole.recipient;
    bool hasChanges = user == null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void validate() {
            final isChanged = user == null || 
                nameController.text != user.name || 
                cnicController.text != user.cnic ||
                idController.text != user.id || 
                selectedRole != user.role;
            final isNotEmpty = nameController.text.isNotEmpty && idController.text.isNotEmpty;
            
            setState(() => hasChanges = isChanged && isNotEmpty);
          }

          nameController.addListener(validate);
          cnicController.addListener(validate);
          idController.addListener(validate);

          return AlertDialog(
            title: Text(user == null ? 'Add New User' : 'Edit User'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  TextField(
                    controller: cnicController,
                    decoration: const InputDecoration(labelText: 'CNIC'),
                  ),
                  if (user != null)
                    TextField(
                      controller: idController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Firebase UID (Read Only)'),
                    )
                  else
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(labelText: 'Initial ID / UID'),
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    initialValue: selectedRole,
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedRole = value);
                        validate();
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Account Type'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: hasChanges ? () {
                  if (user == null) {
                    appProvider.adminAddUser(UserProfile(
                      id: idController.text,
                      name: nameController.text,
                      cnic: cnicController.text,
                      role: selectedRole,
                      balance: 0.0,
                      qrCode: jsonEncode({'id': idController.text, 'type': 'haqdaar_v1'}),
                    ));
                  } else {
                    appProvider.adminUpdateUser(
                      user.id,
                      name: nameController.text,
                      role: selectedRole,
                      // Note: We avoid changing ID/UID here to maintain Firestore consistency
                    );
                    // Add cnic update to appProvider.adminUpdateUser if needed
                    appProvider.updateProfile( // Hacky way to update just cnic via adminUpdate if we add parameters
                      cnic: cnicController.text,
                    );
                  }
                  Navigator.pop(context);
                } : null,
                child: Text(user == null ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AppProvider appProvider, UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              appProvider.adminDeleteUser(user.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
