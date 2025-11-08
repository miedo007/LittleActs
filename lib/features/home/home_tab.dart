import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/models/weekly_gesture.dart';
import 'package:nudge/shared/widgets/Providers/gesture_provider.dart';
import 'package:nudge/shared/widgets/Providers/milestones_provider.dart';
import 'package:nudge/shared/style/palette.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  bool _ensuredBonus = false;
  late Future<int> _refreshesLeftFuture;
  Timer? _countdownTimer;
  Duration? _timeLeft;

  @override
  void initState() {
    super.initState();
    // Ensure bonus generation once per mount; the notifier is idempotent.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_ensuredBonus) {
        _ensuredBonus = true;
        ref.read(weeklyGesturesProvider.notifier).ensureBonusForCurrentWeek();
      }
    });
    // Memoize refresh count to avoid creating a new Future every rebuild
    _refreshesLeftFuture =
        ref.read(weeklyGesturesProvider.notifier).refreshesLeftForCurrentWeek();
    _updateTimeLeft();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTimeLeft());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gestures = ref.watch(weeklyGesturesProvider);
    final notifier = ref.read(weeklyGesturesProvider.notifier);
    final current = notifier.currentWeek();
    final nextPreview = notifier.previewNextWeek();
    final hasCompleted = gestures.any((g) => g.completed);
    WeeklyGesture? bonus;
    if (current.id.isNotEmpty) {
      final id = '${current.id}-bonus';
      final idx = gestures.indexWhere((g) => g.id == id);
      if (idx >= 0) bonus = gestures[idx];
    }
    if (bonus != null && bonus!.title == current.title) {
      bonus = null;
    }
    // Bonus generation is triggered once in initState; avoid per-build scheduling.

    final cs = Theme.of(context).colorScheme;
    final title = current.title.isEmpty ? "This Week's Little Act" : current.title;
    final streak = notifier.streak();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (hasCompleted) ...[
          _streakBanner(context, streak),
          const SizedBox(height: 12),
        ],
        Text("This Week's Little Act",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.title)),
        const SizedBox(height: 8),
        _actCard(context, ref, current, title, cs, _timeLeft),
        const SizedBox(height: 16),
        Text('Extra inspiration',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (bonus == null)
          Text('Generating a small extra idea…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
        else
          _bonusCard(context, ref, bonus),
        const SizedBox(height: 16),
        _upNextWeekCard(context, nextPreview),
      ],
    );
  }

  Widget _actCard(BuildContext context, WidgetRef ref, WeeklyGesture g, String title, ColorScheme cs, Duration? timeLeft) {
    final notifier = ref.read(weeklyGesturesProvider.notifier);
    final imagePath = gestureImageFor(g.title, g.category);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.frameOutline),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imagePath.isEmpty
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.button, AppColors.icon],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  )
                : Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        if (!g.completed && timeLeft != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                const Icon(Icons.hourglass_bottom_rounded, size: 16, color: AppColors.icon),
                const SizedBox(width: 6),
                Text(
                  'Time left: ${_formatTimeLeft(timeLeft)}',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppColors.bodyMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (!g.completed)
                FutureBuilder<int>(
                  future: _refreshesLeftFuture,
                  builder: (context, snap) {
                    final left = snap.data ?? 0;
                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () async {
                        final ok = await notifier.refreshWithinSameCategory();
                        // Refresh the memoized future after a successful refresh
                        setState(() {
                          _refreshesLeftFuture = notifier.refreshesLeftForCurrentWeek();
                        });
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok
                                ? 'Refreshed within same category'
                                : 'Refresh limit reached for this week')));
                      },
                      child: Row(children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.icon.withOpacity(0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.icon),
                        ),
                        const SizedBox(width: 8),
                        Text('$left left',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.bodyMuted, fontWeight: FontWeight.w600)),
                      ]),
                    );
                  },
                )
            ]),
            const SizedBox(height: 6),
            if (g.category.isNotEmpty)
              _categoryTag(context, g.category),
            Text(
              (g.description != null && g.description!.isNotEmpty) ? g.description! : _descFor(g),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurface.withOpacity(0.75)),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.button,
                shape: const StadiumBorder(),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: g.completed
                  ? null
                  : () async {
                      HapticFeedback.mediumImpact();
                      await notifier.markComplete(g.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Marked as completed')));
                    },
              child: Text(g.completed ? 'Completed' : 'Mark as Complete'),
            )
          ]),
        )
      ]),
    );
  }

  Widget _bonusCard(BuildContext context, WidgetRef ref, WeeklyGesture bonus) {
    final notifier = ref.read(weeklyGesturesProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.frameOutline),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(bonus.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
            (bonus.description != null && bonus.description!.isNotEmpty)
                ? bonus.description!
                : "Feeling extra thoughtful? Here's a bonus idea to go beyond the basics.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: bonus.completed
                  ? null
                  : () async {
                      HapticFeedback.mediumImpact();
                      await notifier.markComplete(bonus.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Bonus marked as completed')));
                    },
              child: Text(bonus.completed ? 'Completed' : 'Mark as Complete'),
            ),
          )
        ])
      ]),
    );
  }

  Widget _streakBanner(BuildContext context, int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Current streak',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            '🔥 $streak week${streak == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _upNext(BuildContext context, WidgetRef ref) {
    final milestones = [...ref.read(milestonesProvider)];
    if (milestones.isEmpty) return const SizedBox.shrink();
    milestones.sort((a, b) => a.nextOccurrence().compareTo(b.nextOccurrence()));
    final next = milestones.first;
    final now = DateTime.now();
    final target = next.nextOccurrence();
    final days = target.difference(now).inDays.abs();
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.frameOutline),
      ),
      child: Row(children: [
        Icon(Icons.hourglass_bottom_rounded, color: cs.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text('Up next: ${next.name} in $days day${days == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface)),
        ),
      ]),
    );
  }

  // Up Next preview card (next week's act)
  Widget _upNextWeekCard(BuildContext context, WeeklyGesture next) {
    final cs = Theme.of(context).colorScheme;
    final previewImage = gestureImageFor(next.title, next.category);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.frameOutline),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Up Next…',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: cs.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(next.title.isEmpty ? 'Another thoughtful act' : next.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
                (next.description != null && next.description!.isNotEmpty)
                    ? next.description!
                    : "Get ready for next week's act to strengthen your connection.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ]),
        ),
        const SizedBox(width: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 72,
            height: 72,
            color: AppColors.frameOutline.withOpacity(0.2),
            child: previewImage.isEmpty
                ? const SizedBox.shrink()
                : Image.asset(
                    previewImage,
                    fit: BoxFit.cover,
                  ),
          ),
        )
      ]),
    );
  }

  // Small colored tag for category below the title
  Widget _categoryTag(BuildContext context, String category) {
    final (label, color) = _categoryMeta(category);
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // Maps incoming category to label and color
  (String, Color) _categoryMeta(String raw) {
    final c = raw.toLowerCase();
    if (c.contains('service')) return ('Acts of Service', const Color(0xFF00B894));
    if (c.contains('time')) return ('Quality Time', const Color(0xFF0984E3));
    if (c.contains('gift')) return ('Receiving Gifts', const Color(0xFFFDCB6E));
    if (c.contains('touch')) return ('Physical Touch', const Color(0xFFFF7675));
    if (c.contains('word') || c.contains('affirm')) return ('Words of Affirmation', const Color(0xFF6C63FF));
    return ('Thoughtful Act', AppColors.button);
  }

  String _descFor(WeeklyGesture g) {
    final cat = g.category.toLowerCase();
    if (cat.contains('time')) {
      return 'Plan a short moment together this week—a walk, a chat, or tea time.';
    } else if (cat.contains('service')) {
      return 'Do a small act that makes their day easier—something thoughtful and helpful.';
    } else if (cat.contains('gift')) {
      return 'Surprise them with a tiny token—something simple that shows you care.';
    } else if (cat.contains('touch')) {
      return 'Offer warm closeness—an extra hug, a hand squeeze, or a cozy moment.';
    } else if (cat.contains('word') || cat.contains('affirm')) {
      return 'Share genuine words of appreciation to brighten their day.';
    }
    return "Start their day with a warm surprise that shows you’re thinking of them.";
  }

  void _updateTimeLeft() {
    final notifier = ref.read(weeklyGesturesProvider.notifier);
    final current = notifier.currentWeek();
    if (current.id.isEmpty) {
      if (mounted) {
        setState(() => _timeLeft = null);
      }
      return;
    }
    final weekEnd = current.weekStart.add(const Duration(days: 7));
    final remaining = weekEnd.difference(DateTime.now());
    final normalized = remaining.isNegative ? Duration.zero : remaining;
    if (!mounted) return;
    setState(() => _timeLeft = normalized);
  }

  String _formatTimeLeft(Duration duration) {
    if (duration.inSeconds <= 0) return 'Week wrapping up soon';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    if (days > 0) {
      return '$days day${days == 1 ? '' : 's'} ${hours}h left';
    }
    if (hours > 0) {
      return '$hours hour${hours == 1 ? '' : 's'} ${minutes}m left';
    }
    return '$minutes min left';
  }
}
