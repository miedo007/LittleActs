import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nudge/models/weekly_gesture.dart';
import 'package:nudge/shared/widgets/Providers/gesture_provider.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/Services/notification_service.dart';
import 'package:nudge/shared/widgets/glass_card.dart';
import 'package:nudge/shared/widgets/pressable.dart';
import 'package:nudge/shared/widgets/calm_background.dart';

class NudgeOfWeekScreen extends ConsumerWidget {
  const NudgeOfWeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(weeklyGesturesProvider);
    final notifier = ref.read(weeklyGesturesProvider.notifier);
    final isPro = ref.watch(premiumProvider);

    final WeeklyGesture current = notifier.currentWeek();
    final bool isReady = current.id.isNotEmpty && current.title.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("This Week's Nudge"),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.goNamed('settings'),
          ),
        ],
      ),
      body: CalmBackground(
        child: isReady
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  GlassCard(
                    child: ListTile(
                      title: Text(current.title, style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text('Category:  • Week of '),
                      trailing: current.completed
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.goNamed('giftSuggestions'),
                          child: const Text('See gift ideas'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Pressable(
                          onTap: current.completed
                              ? null
                              : () async {
                                  await notifier.markComplete(current.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Nice! Marked as done.')),
                                  );
                                },
                          child: FilledButton.icon(onPressed: current.completed ? null : () async { await notifier.markComplete(current.id); if (!context.mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nice! Marked as done.'))); }, icon: const Icon(Icons.favorite),
                            label: Text(current.completed ? 'Completed' : 'Mark as done'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => NotificationService().showNowTest('Test notification', 'It works!'),
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('Send test notification'),
                  ),
                  const Spacer(),
                  Center(
                    child: isPro
                        ? Text(
                            'Current streak: ${notifier.streak()} week(s)',
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        : TextButton.icon(
                            onPressed: () => context.goNamed('paywall'),
                            icon: const Icon(Icons.lock_outline),
                            label: const Text('Unlock streaks with Premium'),
                          ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}






