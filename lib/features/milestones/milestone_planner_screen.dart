import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:nudge/models/milestone.dart';
import 'package:nudge/shared/widgets/Providers/milestones_provider.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';

class MilestonePlannerScreen extends ConsumerStatefulWidget {
  const MilestonePlannerScreen({super.key});

  @override
  ConsumerState<MilestonePlannerScreen> createState() =>
      _MilestonePlannerScreenState();
}

class _MilestonePlannerScreenState
    extends ConsumerState<MilestonePlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  DateTime? _pickedDate;
  bool _repeatYearly = true;

  @override
  Widget build(BuildContext context) {
    final milestones = [...ref.watch(milestonesProvider)];
    milestones.sort((a, b) => a.nextOccurrence().compareTo(b.nextOccurrence()));
    final isPro = ref.watch(premiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestone Planner'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.goNamed('settings'),
          ),
        ],
      ),
      body: CalmBackground(
        child: Column(
          children: [
            // --- Upsell banner for Free users ---
            if (!isPro)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: ListTile(
                    title: const Text('Free plan: 1 milestone'),
                    subtitle: const Text('Upgrade to add unlimited milestones.'),
                    trailing: TextButton(
                      onPressed: () => context.goNamed('paywall'),
                      child: const Text('Upgrade'),
                    ),
                  ),
                ),
              ),

            // --- Add form ---
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Styled tile for milestone name input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3066),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Milestone name (e.g., Birthday, Anniversary)',
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3066),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_month, color: Colors.white),
                            label: Text(
                              _pickedDate == null
                                  ? 'Pick date'
                                  : DateFormat.yMMMMd().format(_pickedDate!),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _pickedDate ?? now,
                                firstDate: DateTime(now.year - 50),
                                lastDate: DateTime(now.year + 50),
                              );
                              if (picked != null) {
                                setState(() => _pickedDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _repeatYearly,
                              onChanged: (v) => setState(() => _repeatYearly = v ?? true),
                              side: const BorderSide(color: Colors.white),
                              checkColor: const Color(0xFF0F3066),
                              activeColor: Colors.white,
                            ),
                            const Text('Repeat yearly', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3066),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            _pickedDate != null) {
                          // Premium gate: Free users can only have 1 milestone
                          if (!isPro && milestones.isNotEmpty) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Premium required for more milestones.',
                                ),
                                action: SnackBarAction(
                                  label: 'Upgrade',
                                  onPressed: () => context.goNamed('paywall'),
                                ),
                              ),
                            );
                            return;
                          }

                          final m = Milestone(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: _nameCtrl.text.trim(),
                            date: _pickedDate!,
                            repeatYearly: _repeatYearly,
                          );
                          await ref.read(milestonesProvider.notifier).add(m);
                          setState(() {
                            _nameCtrl.clear();
                            _pickedDate = null;
                            _repeatYearly = true;
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Milestone added')),
                          );
                        }
                      },
                      child: const Text('Add milestone'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // --- List ---
            Expanded(
              child: milestones.isEmpty
                  ? const Center(
                      child: Text(
                        'No milestones yet.\nAdd a birthday, anniversary, or any date.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: milestones.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final m = milestones[i];
                        final next = m.nextOccurrence();
                        final today = DateTime.now(); // date-only diff, not time
                        final d0 = DateTime(today.year, today.month, today.day);
                        final d1 = DateTime(next.year, next.month, next.day);
                        final diff = d1.difference(d0).inDays;

                        String chipText;
                        if (diff == 0) {
                          chipText = 'Today ðŸŽ‰';
                        } else if (diff > 0) {
                          chipText = 'In $diff day${diff == 1 ? '' : 's'}';
                        } else {
                          chipText =
                              '${diff.abs()} day${diff == -1 ? '' : 's'} ago';
                        }

                        return Dismissible(
                          key: ValueKey(m.id),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 16),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => ref
                              .read(milestonesProvider.notifier)
                              .remove(m.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3066),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: ListTile(
                              title: Text(
                                m.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                m.repeatYearly
                                    ? 'Next: ${DateFormat.yMMMMd().format(next)}'
                                    : 'Date: ${DateFormat.yMMMMd().format(m.date)}',
                                style: TextStyle(color: Colors.white.withOpacity(0.85)),
                              ),
                              trailing: Chip(
                                label: Text(chipText),
                                backgroundColor: Colors.white.withOpacity(0.15),
                                side: const BorderSide(color: Colors.white),
                                labelStyle: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.goNamed('nudgeOfWeek'),
                    child: const Text('Next: Weekly Nudge'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

