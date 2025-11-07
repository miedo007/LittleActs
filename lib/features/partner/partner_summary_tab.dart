import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/shared/widgets/Providers/milestones_provider.dart';
import 'package:intl/intl.dart';
import 'package:nudge/models/partner.dart';
import 'package:nudge/shared/style/palette.dart';
import 'package:nudge/models/milestone.dart';

class PartnerSummaryTab extends ConsumerWidget {
  const PartnerSummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = ref.watch(partnerProvider);
    final cs = Theme.of(context).colorScheme;

    if (partner == null) {
      return Center(
        child: Text('No partner yet. Add one in Settings.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant)),
      );
    }

    final ratings = <String, int>{
      'Quality Time': (partner.qualityTime ?? 0).clamp(0, 5),
      'Words of Affirmation': (partner.wordsOfAffirmation ?? 0).clamp(0, 5),
      'Acts of Service': (partner.actsOfService ?? 0).clamp(0, 5),
      'Physical Touch': (partner.physicalTouch ?? 0).clamp(0, 5),
      'Receiving Gifts': (partner.receivingGifts ?? 0).clamp(0, 5),
    };
    final total = ratings.values.fold<int>(0, (a, b) => a + b);
    final pct = total > 0
        ? {for (final e in ratings.entries) e.key: ((e.value / total) * 100).round()}
        : {for (final e in ratings.entries) e.key: 0};

    Color colorFor(String key) {
      switch (key) {
        case 'Words of Affirmation':
          return const Color(0xFF6C63FF);
        case 'Acts of Service':
          return const Color(0xFF00B894);
        case 'Physical Touch':
          return const Color(0xFFFF7675);
        case 'Receiving Gifts':
          return const Color(0xFFFDCB6E);
        case 'Quality Time':
          return const Color(0xFF0984E3);
        default:
          return cs.primary;
      }
    }

    final milestones = [...ref.watch(milestonesProvider)];
    milestones.sort((a, b) => a.nextOccurrence().compareTo(b.nextOccurrence()));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Frame 1: Partner name + together since
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${_possessive(partner.name)} profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                if (partner.togetherSince != null)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.favorite, color: AppColors.button),
                          SizedBox(width: 6),
                          Text('Together for', style: TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _togetherFor(partner.togetherSince!),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  )
                else
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await _pickDateCupertino(
                          context,
                          DateTime(now.year, now.month, now.day),
                          DateTime(now.year - 20, 1, 1),
                          now,
                        );
                        if (picked != null) {
                          final notifier = ref.read(partnerProvider.notifier);
                          await notifier.savePartner(partner.copyWith(togetherSince: picked));
                        }
                      },
                      child: const Text('Set together since'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Love Language',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                      onPressed: () => context.pushNamed('profileInsights'),
                      child: const Text('View full profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RepaintBoundary(
                  child: _LoveDonut(
                    pct: pct.map((k, v) => MapEntry(k, v.toDouble())),
                    colorFor: colorFor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Milestones',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
              onPressed: () => context.pushNamed('milestonePlanner'),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add milestone'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (milestones.isEmpty)
          Text('No milestones yet. Add birthdays, anniversaries, and more.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant))
        else
          Column(
            children: [
              for (final m in milestones.take(3))
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _titleFor(m, partner.name),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Next: ${DateFormat.yMMMMd().format(m.nextOccurrence())}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.button.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.button),
                        ),
                        child: Text(
                          _inDays(m.nextOccurrence()),
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: AppColors.button, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _chip(BuildContext context, String text) {
    return Chip(label: Text(text));
  }
}

class _LoveDonut extends StatefulWidget {
  final Map<String, double> pct; // 0..100 values per language
  final Color Function(String key) colorFor;
  const _LoveDonut({required this.pct, required this.colorFor});

  @override
  State<_LoveDonut> createState() => _LoveDonutState();
}

class _LoveDonutState extends State<_LoveDonut> {
  @override
  Widget build(BuildContext context) {
    final sorted = widget.pct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final primary = sorted.isNotEmpty ? sorted.first.key : null;
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, c) {
      final size = 140.0;
      return Row(
        children: [
          RepaintBoundary(
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _DonutPainter(
                  pct: widget.pct,
                  colorFor: widget.colorFor,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(primary ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                      if (primary != null)
                        Text('${widget.pct[primary]?.round() ?? 0}%',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in sorted)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: widget.colorFor(e.key), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(e.key)),
                      Text('${e.value.round()}%'),
                    ]),
                  ),
              ],
            ),
          )
        ],
      );
    });
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, double> pct;
  final Color Function(String key) colorFor;
  _DonutPainter({required this.pct, required this.colorFor});

  @override
  void paint(Canvas canvas, Size size) {
    final total = pct.values.fold<double>(0, (a, b) => a + b);
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2.0 * 0.95;
    final thickness = radius * 0.28;
    final sorted = pct.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    double start = -math.pi / 2; // top
    for (final e in sorted) {
      final double sweep = total == 0 ? 0.0 : (e.value / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = colorFor(e.key);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.pct != pct;
  }
}

String _togetherFor(DateTime since) {
  final now = DateTime.now();
  int years = now.year - since.year;
  int months = now.month - since.month;
  int days = now.day - since.day;
  if (days < 0) {
    final prevMonth = DateTime(now.year, now.month, 0).day;
    days += prevMonth;
    months -= 1;
  }
  if (months < 0) {
    months += 12;
    years -= 1;
  }
  final parts = <String>[];
  if (years > 0) parts.add('$years year${years == 1 ? '' : 's'}');
  if (months > 0) parts.add('$months month${months == 1 ? '' : 's'}');
  if (days > 0 || parts.isEmpty) parts.add('$days day${days == 1 ? '' : 's'}');
  return parts.join(', ');
}
 
String _possessive(String name) {
  final n = (name.trim().isEmpty) ? 'Partner' : name.trim();
  // Basic possessive helper: James' vs Zineb's
  if (n.endsWith('s') || n.endsWith('S')) return "$n'";
  return "$n's";
}

Future<DateTime?> _pickDateCupertino(
  BuildContext context,
  DateTime initialDate,
  DateTime firstDate,
  DateTime lastDate,
) async {
  DateTime temp = initialDate;
  return showModalBottomSheet<DateTime>(
    context: context,
    builder: (ctx) => SizedBox(
      height: 280,
      child: Column(children: [
        Expanded(
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: initialDate,
            minimumDate: firstDate,
            maximumDate: lastDate,
            onDateTimeChanged: (d) => temp = d,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, temp),
                child: const Text('Done'),
              ),
            ),
          ]),
        )
      ]),
    ),
  );
}
String _inDays(DateTime date) {
  final now = DateTime.now();
  final diff = date.difference(now).inDays;
  if (diff == 0) return 'Today';
  if (diff > 0) return 'In $diff d';
  return '${diff.abs()}d ago';
}

String _titleFor(Milestone milestone, String partnerName) {
  if (milestone.id == 'birthday') {
    final first = partnerName.split(' ').first;
    return "$first's Birthday";
  }
  if (milestone.id == 'anniversary') {
    return 'Relationship Anniversary';
  }
  return milestone.name;
}
