import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:microrealeaste/database/backup_service.dart';
import 'package:microrealeaste/database/data_service.dart';
import 'package:microrealeaste/providers/auth_provider.dart';
import 'package:microrealeaste/providers/theme_provider.dart';
import 'package:microrealeaste/widgets/color_picker_widget.dart';
import 'package:microrealeaste/widgets/framework_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:microrealeaste/pages/user_profile_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _autoBackup = true;
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoBackup = prefs.getBool('auto_backup') ?? true;
      _currency = prefs.getString('currency') ?? 'USD';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('auto_backup', _autoBackup);
    await prefs.setString('currency', _currency);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FrameworkPage(
      title: 'Settings',
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Appearance'),
              _buildThemeSelector(),
              const SizedBox(height: 24),
              _buildSectionHeader('Preferences'),
              _buildNotificationToggle(),
              _buildAutoBackupToggle(),
              _buildCurrencySelector(),
              const SizedBox(height: 24),
              _buildSectionHeader('Data Management'),
              _buildDataManagementOptions(),
              const SizedBox(height: 24),
              _buildSectionHeader('Support'),
              _buildSupportOptions(),
              const SizedBox(height: 24),
              _buildSectionHeader('About'),
              _buildAboutOptions(),
              const SizedBox(height: 24),
              _buildSectionHeader('Account'),
              _buildAccountOptions(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeProvider).mode;
    final appTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final primaryColor = appTheme.primaryColor;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(themeNotifier.getThemeDisplayName(currentTheme)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(themeNotifier),
          ),
          const Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: primaryColor,
              child: const Icon(Icons.color_lens, color: Colors.white),
            ),
            title: const Text('Theme Color'),
            subtitle: const Text('Customize primary color'),
            onTap: () async {
              final picked = await showColorPicker(
                context: context,
                initialColor: primaryColor,
                title: 'Pick a theme color',
              );
              if (picked != null) {
                await themeNotifier.setPrimaryColor(picked);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: SwitchListTile(
        secondary: const Icon(Icons.notifications_outlined),
        title: const Text('Notifications'),
        subtitle: const Text('Receive rent and maintenance alerts'),
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() {
            _notificationsEnabled = value;
          });
          _saveSettings();
        },
      ),
    );
  }

  Widget _buildAutoBackupToggle() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: SwitchListTile(
        secondary: const Icon(Icons.backup_outlined),
        title: const Text('Auto Backup'),
        subtitle: const Text('Automatically backup data daily'),
        value: _autoBackup,
        onChanged: (value) {
          setState(() {
            _autoBackup = value;
          });
          _saveSettings();
        },
      ),
    );
  }

  Widget _buildCurrencySelector() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: const Icon(Icons.attach_money),
        title: const Text('Currency'),
        subtitle: Text('Current: $_currency'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showCurrencyDialog,
      ),
    );
  }

  Widget _buildDataManagementOptions() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            subtitle: const Text('Export all data to file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _backupData,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            subtitle: const Text('Import data from backup file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _restoreData,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red.shade600),
            title: Text('Clear All Data', style: TextStyle(color: Colors.red.shade600)),
            subtitle: const Text('Permanently delete all data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearAllData,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptions() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & FAQ'),
            subtitle: const Text('Get help and find answers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showHelp,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            subtitle: const Text('Report issues or suggest features'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _sendFeedback,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate App'),
            subtitle: const Text('Rate us on the app store'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _rateApp,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutOptions() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAboutDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we handle your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showPrivacyPolicy,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            subtitle: const Text('App usage terms and conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showTermsOfService,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOptions() {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: const Text('Edit your profile and preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserProfilePage()),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade600),
            title: Text('Sign Out', style: TextStyle(color: Colors.red.shade600)),
            subtitle: const Text('Sign out of your account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(ThemeNotifier themeNotifier) {
    final currentTheme = ref.read(themeProvider).mode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(themeNotifier.getThemeDisplayName(mode)),
              subtitle: Text(themeNotifier.getThemeDescription(mode)),
              value: mode,
              groupValue: currentTheme,
              onChanged: (value) async {
                if (value != null) {
                  await themeNotifier.setTheme(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    final currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'INR'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return RadioListTile<String>(
                title: Text(currency),
                value: currency,
                groupValue: _currency,
                onChanged: (value) {
                  setState(() {
                    _currency = value!;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _backupData() async {
    if (!mounted) return;
    _showLoadingDialog('Creating backup...');

    try {
      final jsonString = await BackupService.createBackupJson();
      final fileName = 'microrealeaste_backup_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.json';

      if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Use file_picker for desktop and web
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save your backup file',
          fileName: fileName,
          bytes: utf8.encode(jsonString),
        );
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result != null ? 'Backup saved successfully!' : 'Backup canceled.'),
              backgroundColor: result != null ? Colors.green : Colors.orange,
            ),
          );
        }
      } else {
        // Use share_plus for mobile
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsString(jsonString);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          final box = context.findRenderObject() as RenderBox?;
          Share.shareXFiles(
            [XFile(file.path, mimeType: 'application/json')],
            subject: 'MicroRealEstate Backup',
            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _restoreData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text('This will replace all current data with the backup. This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restore canceled.'), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      if (!mounted) return;
      _showLoadingDialog('Restoring data...');

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      await BackupService.restoreFromBackup(jsonString);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete all properties, tenants, payments, and maintenance requests. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await DataService.clearAllData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Frequently Asked Questions:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Q: How do I add a new property?'),
              Text('A: Go to Properties tab and tap the + button.'),
              SizedBox(height: 8),
              Text('Q: How do I track rent payments?'),
              Text('A: Use the Payments tab to view and manage all rent payments.'),
              SizedBox(height: 8),
              Text('Q: How do I submit maintenance requests?'),
              Text('A: Go to tenant or property details and use the Maintenance tab.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUri(Uri uri) async {
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $uri'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendFeedback() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@microrealeaste.com',
      query: 'subject=App Feedback (v1.0.0)',
    );
    _launchUri(emailLaunchUri);
  }

  void _rateApp() {
    // Note: You'll need to replace these with your actual app store IDs.
    const androidAppId = 'com.example.microrealeaste';
    const iosAppId = '1234567890';

    final Uri uri;
    if (kIsWeb) {
      // Cannot determine mobile OS on web, open a generic page or website
      uri = Uri.parse('https://yourappwebsite.com/review');
    } else if (Platform.isAndroid) {
      uri = Uri.parse('https://play.google.com/store/apps/details?id=$androidAppId');
    } else if (Platform.isIOS) {
      uri = Uri.parse('https://apps.apple.com/app/id$iosAppId');
    } else {
      // Fallback for desktop or other platforms
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App rating is not available on this platform.')),
      );
      return;
    }
    _launchUri(uri);
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'MicroRealEstate',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.home, size: 48),
      children: [
        const Text('A comprehensive property management solution for landlords and property managers.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Property management'),
        const Text('• Tenant tracking'),
        const Text('• Rent payment monitoring'),
        const Text('• Maintenance request handling'),
        const Text('• Financial reporting'),
      ],
    );
  }

  void _showPrivacyPolicy() {
    final uri = Uri.parse('https://www.freeprivacypolicy.com/live/your-policy-url'); // Replace with your actual URL
    _launchUri(uri);
  }

  void _showTermsOfService() {
    final uri = Uri.parse('https://www.termsofservicegenerator.net/live.php?token=your-token'); // Replace with your actual URL
    _launchUri(uri);
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileInfoRow('Name', currentUser.fullName),
            _buildProfileInfoRow('Email', currentUser.email),
            if (currentUser.phoneNumber != null)
              _buildProfileInfoRow('Phone', currentUser.phoneNumber!),
            _buildProfileInfoRow('Role', currentUser.roleDisplayName),
            _buildProfileInfoRow('Status', currentUser.isActive ? 'Active' : 'Inactive'),
            _buildProfileInfoRow('Email Verified', currentUser.emailVerified ? 'Yes' : 'No'),
            _buildProfileInfoRow('Member Since', 
              '${currentUser.createdAt.day}/${currentUser.createdAt.month}/${currentUser.createdAt.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
