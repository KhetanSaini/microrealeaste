import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:microrealeaste/providers/auth_provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// User profile page for editing photo, contact info, and notification preferences
class UserProfilePage extends HookConsumerWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user found.')),
      );
    }
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');
    final notificationPref = useState(user.notificationsEnabled);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: user.profilePhotoUrl != null
                        ? NetworkImage(user.profilePhotoUrl!)
                        : null,
                    child: user.profilePhotoUrl == null
                        ? Text(user.firstName[0].toUpperCase(), style: const TextStyle(fontSize: 32))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Add photo picker
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              value: notificationPref.value,
              onChanged: (value) {
                notificationPref.value = value;
              },
              title: const Text('Enable Notifications'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final updatedUser = user.copyWith(
                  phoneNumber: phoneController.text.trim(),
                  notificationsEnabled: notificationPref.value,
                );
                await ref.read(authProvider.notifier).updateProfile(updatedUser);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
} 