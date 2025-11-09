import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nudge/models/partner.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/Services/notification_service.dart';
import 'package:nudge/shared/widgets/premium_lock_card.dart';

class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isPremium = ref.watch(premiumProvider);
    final premiumNotifier = ref.read(premiumProvider.notifier);
    final partner = ref.watch(partnerProvider);
    final notificationsOn = partner?.notificationOptIn ?? false;

    Future<void> toggleNotifications(bool value) async {
      if (partner == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Add your partner profile first.')));
        return;
      }
      if (!value) {
        await NotificationService().cancelAll();
        await ref
            .read(partnerProvider.notifier)
            .savePartner(partner.copyWith(notificationOptIn: false));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Notifications disabled')));
        return;
      }
      final granted = await NotificationService().requestPermissions();
      if (granted) {
        await ref
            .read(partnerProvider.notifier)
            .savePartner(partner.copyWith(notificationOptIn: true));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Notifications enabled')));
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please enable notifications in Settings to stay updated.')));
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
        Text('Account', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (!isPremium) ...[
          PremiumLockCard(
            title: 'Stay in sync with Premium',
            description: 'Unlock partner data backup, extra planning tools, and notification scheduling.',
          ),
          const SizedBox(height: 12),
        ],

        Card(
          child: ListTile(
            leading: Icon(Icons.workspace_premium_rounded, color: cs.primary),
            title: Text(isPremium ? "You're Premium" : 'Upgrade to Premium'),
            subtitle:
                Text(isPremium ? 'Thanks for the support!' : 'Unlock streaks and smarter suggestions'),
            trailing: isPremium
                ? null
                : FilledButton(
                    onPressed: () {
                      context.pushNamed('paywall');
                    },
                    child: const Text('Upgrade'),
                  ),
          ),
        ),

        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: const Text('Restore Purchases'),
            onTap: () async {
              await premiumNotifier.restore();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Restore attempted')));
            },
          ),
        ),

        const SizedBox(height: 8),

        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_active_rounded),
            title: const Text('Notifications'),
            value: notificationsOn,
            onChanged: partner == null ? null : toggleNotifications,
          ),
        ),

        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () async {
              final uri = Uri.parse(
                  'https://docs.google.com/document/d/1GGduvRVdPEk4ASX04e5As3OERoDEkq9NyKAhaqj2nJg/edit?usp=sharing');
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Could not open Privacy Policy')));
              }
            },
          ),
        ),

        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            onTap: () async {
              final uri = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Could not open Terms of Service')));
              }
            },
          ),
        ),

        if (!kReleaseMode)
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Send test notification (debug)'),
              onTap: () => NotificationService().showNowTest('Test notification', 'It works!'),
            ),
          ),
        ],
      ),
    );
  }
}
