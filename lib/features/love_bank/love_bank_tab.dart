import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:nudge/models/weekly_gesture.dart";
import "package:nudge/shared/style/palette.dart";
import "package:nudge/shared/widgets/Providers/gesture_provider.dart";

class LoveBankTab extends ConsumerWidget {
  const LoveBankTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<WeeklyGesture> gestures = ref.watch(weeklyGesturesProvider);
    final notifier = ref.read(weeklyGesturesProvider.notifier);
    final completed = notifier.completedActs();
    final cs = Theme.of(context).colorScheme;
    final totalActs = completed.length;
    final longest = notifier.longestStreak();
    DateTime? earliestGesture;
    if (gestures.isNotEmpty) {
      earliestGesture = gestures
          .map((g) => g.weekStart)
          .reduce((a, b) => a.isBefore(b) ? a : b);
    }
    final joinWeekStart = _startOfWeek(earliestGesture ?? DateTime.now());
    final displayYear = DateTime.now().year;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Love Bank',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Every small act adds up to something big \u2665',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Row(children: [
          _metricCard(context, 'Total Acts', totalActs.toString(), flame: false),
          const SizedBox(width: 12),
          _metricCard(context, 'Longest Streak', '$longest', flame: true),
        ]),
        const SizedBox(height: 20),
        Text(
          'Your $displayYear Year In Review',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.all(16),
            child: RepaintBoundary(
              child: _Heatmap52(
                gestures: gestures,
                joinWeekStart: joinWeekStart,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Last Thoughtful Moments',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (completed.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Text(
                'Complete your first act to start building a highlight reel.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          )
        else
      for (final g in completed.take(5))
        Card(
          child: ListTile(
            leading: Text(_emojiGlyph(g.category), style: const TextStyle(fontSize: 20)),
            title: Text(
              g.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              DateFormat.yMMMEd().format(g.completedAt ?? g.weekStart),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            trailing: Text(
              g.category.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: _loveColor(context, g.category)),
            ),
          ),
        ),
        if (!kReleaseMode) ...[
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.button,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await notifier.simulateYearOfActs();
              messenger.showSnackBar(
                const SnackBar(content: Text('Simulated a year of acts (debug only)')),
              );
            },
            icon: const Icon(Icons.bolt),
            label: const Text('Simulate Year (debug)'),
          ),
          const SizedBox(height: 8),
          Text(
            'Populates the Love Bank with 12 months of completed acts for fast screenshots.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  static String _emojiGlyph(String category) {
    switch (category.toLowerCase()) {
      case 'gifts':
        return '🎁';
      case 'service':
      case 'acts of service':
        return '🧺';
      case 'time':
      case 'quality time':
        return '⏰';
      case 'touch':
        return '🤝';
      case 'affirmation':
      case 'words':
        return '💬';
      default:
        return '✨';
    }
  }

}

enum _WeekStatus { past, completed, missed, upcoming, current }

class _Heatmap52 extends StatelessWidget {
  final List<WeeklyGesture> gestures;
  final DateTime joinWeekStart;
  const _Heatmap52({required this.gestures, required this.joinWeekStart});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final currentWeek = _startOfWeek(now);
    final joinWeek = _startOfWeek(joinWeekStart);

    final completedWeeks = <DateTime>{
      for (final g in gestures.where((g) => g.completed))
        _startOfWeek(g.completedAt ?? g.weekStart)
    };

    // Helper: Sundays inside the given month
    List<DateTime> weeksInMonth(int year, int month) {
      final first = DateTime(year, month, 1);
      final last = DateTime(year, month + 1, 0);
      DateTime cur = first;
      while (cur.weekday % 7 != 0) {
        cur = cur.add(const Duration(days: 1));
      }
      final list = <DateTime>[];
      while (!cur.isAfter(last)) {
        list.add(cur);
        cur = cur.add(const Duration(days: 7));
      }
      return list;
    }

    Color colorFor(_WeekStatus status) {
      switch (status) {
        case _WeekStatus.completed:
          return const Color(0xFF4CAF6E);
        case _WeekStatus.missed:
          return AppColors.button;
        case _WeekStatus.past:
          return const Color(0xFFDAD7D0);
        case _WeekStatus.upcoming:
          return const Color(0xFFF3EFE8);
        case _WeekStatus.current:
          return Colors.white;
      }
    }

    _WeekStatus statusFor(DateTime ws) {
      if (ws.isBefore(joinWeek)) return _WeekStatus.past;
      if (ws.isAfter(currentWeek)) return _WeekStatus.upcoming;
      if (ws == currentWeek) return _WeekStatus.current;
      if (completedWeeks.contains(ws)) return _WeekStatus.completed;
      return _WeekStatus.missed;
    }

    return LayoutBuilder(builder: (context, constraints) {
      const monthsPerRow = 3;
      const monthGap = 12.0;
      const dotSize = 14.0;
      const dotGap = 6.0;
      final width = constraints.maxWidth;
      final monthWidth = ((width - (monthsPerRow - 1) * monthGap) / monthsPerRow).clamp(120.0, 9999.0);

      Widget buildMonth(int year, int month) {
        final weeks = weeksInMonth(year, month);
        final outlineColor = Theme.of(context).colorScheme.primary;
        return SizedBox(
          width: monthWidth,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              ['January','February','March','April','May','June','July','August','September','October','November','December'][month - 1],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Row(children: [
              for (int i = 0; i < weeks.length; i++) ...[
                () {
                  final status = statusFor(weeks[i]);
                  return _WeekDot(
                    size: dotSize,
                    color: colorFor(status),
                    outline: status == _WeekStatus.current ? Border.all(color: outlineColor, width: 2) : null,
                  );
                }(),
                if (i != weeks.length - 1) const SizedBox(width: dotGap),
              ]
            ])
          ]),
        );
      }

      final year = now.year;
      final months = <Widget>[for (int m = 1; m <= 12; m++) buildMonth(year, m)];

      // Legend
      Widget legendBox(Color color) =>
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: monthGap,
            runSpacing: 12,
            children: months,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _legendEntry(context, legendBox(colorFor(_WeekStatus.past)), 'Past Weeks'),
              _legendEntry(context, legendBox(colorFor(_WeekStatus.completed)), 'Completed'),
              _legendEntry(context, legendBox(colorFor(_WeekStatus.missed)), 'Missed'),
              _legendEntry(context, legendBox(colorFor(_WeekStatus.upcoming)), 'Upcoming'),
              _legendEntry(
                context,
                _WeekDot(
                  size: 14,
                  color: Colors.white,
                  outline: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                'Current Week',
              ),
            ],
          )
        ],
      );
    });
  }

  Widget _legendEntry(BuildContext context, Widget swatch, String label) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      swatch,
      const SizedBox(width: 6),
      Text(label, style: textStyle),
    ]);
  }
}

class _WeekDot extends StatelessWidget {
  final double size;
  final Color color;
  final BoxBorder? outline;
  const _WeekDot({required this.size, required this.color, this.outline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
        border: outline,
      ),
    );
  }
}

Color _loveColor(BuildContext context, String category) {
  switch (category.toLowerCase()) {
    case 'words':
    case 'affirmation':
      return const Color(0xFF6C63FF);
    case 'service':
    case 'acts of service':
      return const Color(0xFF00B894);
    case 'touch':
      return const Color(0xFFFF7675);
    case 'gifts':
      return const Color(0xFFFDCB6E);
    case 'time':
    case 'quality time':
      return const Color(0xFF0984E3);
    default:
      return Theme.of(context).colorScheme.primary;
  }
}
 
Widget _metricCard(BuildContext context, String label, String value, {bool flame = false}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        Text('${flame ? '🔥 ' : ''}$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
      ]),
    ),
  );
}

DateTime _startOfWeek(DateTime date) {
  final base = DateTime(date.year, date.month, date.day);
  final weekday = base.weekday % 7; // Sunday => 0
  final start = base.subtract(Duration(days: weekday));
  return DateTime(start.year, start.month, start.day);
}
