import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/Providers/milestones_provider.dart';
import 'package:nudge/shared/Services/notification_service.dart';

class AccountTab extends ConsumerStatefulWidget {
  const AccountTab({super.key});

  @override
  ConsumerState<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends ConsumerState<AccountTab> {
  bool _notificationsEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _loading = false;
    });
  }

  Future<void> _setNotifications(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', v);
    setState(() => _notificationsEnabled = v);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(v ? 'Notifications enabled' : 'Notifications disabled')),
    );
  }

  Future<void> _deleteAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text('This removes partner info, milestones, and gesture history from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    // Clear providers and persisted keys
    await ref.read(partnerProvider.notifier).clear();
    await ref.read(milestonesProvider.notifier).clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('weekly_gestures');
    await prefs.remove('has_completed_setup');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All local data deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPremium = ref.watch(premiumProvider);
    final premium = ref.read(premiumProvider.notifier);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Account', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        // Upgrade to Premium
        Card(
          child: ListTile(
            leading: Icon(Icons.workspace_premium_rounded, color: cs.primary),
            title: Text(isPremium ? 'You\'re Premium' : 'Upgrade to Premium'),
            subtitle: Text(isPremium ? 'Thanks for the support!' : 'Unlock streaks and smarter suggestions'),
            trailing: isPremium
                ? null
                : FilledButton(
                    onPressed: () async {
                      if (!mounted) return;
                      context.pushNamed('paywall');
                    },
                    child: const Text('Upgrade'),
                  ),
          ),
        ),

        const SizedBox(height: 8),

        // Restore purchase
        Card(
          child: ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: const Text('Restore Purchases'),
            onTap: () async {
              await premium.restore();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore attempted')));
            },
          ),
        ),

        const SizedBox(height: 8),

        // Notifications toggle
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_active_rounded),
            title: const Text('Notifications'),
            value: _notificationsEnabled,
            onChanged: _setNotifications,
          ),
        ),

        const SizedBox(height: 8),

        // Privacy Policy
        Card(
          child: ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () async {
              final uri = Uri.parse('https://docs.google.com/document/d/1GGduvRVdPEk4ASX04e5As3OERoDEkq9NyKAhaqj2nJg/edit?usp=sharing');
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Privacy Policy')));
              }
            },
          ),
        ),

        const SizedBox(height: 8),

        // Terms of Service
        Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            onTap: () async {
              final uri = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Terms of Service')));
              }
            },
          ),
        ),

        const SizedBox(height: 8),

        // Delete Data
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: const Text('Delete Data'),
            textColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            onTap: _deleteAllData,
          ),
        ),
        const SizedBox(height: 8),
        if (!kReleaseMode)
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Send test notification (debug)'),
              onTap: () => NotificationService().showNowTest('Test notification', 'It works!'),
            ),
          ),
      ],
    );
  }
}

class _SimpleDocDialog extends StatelessWidget {
  final String title;
  const _SimpleDocDialog({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(title),
      content: Text(
          'Coming soon. You can add a WebView or open an external link here.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}
