import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/models/partner.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:nudge/shared/widgets/Providers/milestones_provider.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/widgets/Providers/gesture_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _favoritesCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = ref.read(partnerProvider);
    if (p != null) {
      _favoritesCtrl.text = p.favorites ?? '';
      _budgetCtrl.text = p.budget ?? '';
    }
  }

  @override
  void dispose() {
    _favoritesCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partner = ref.watch(partnerProvider);
    if (partner == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.goNamed('nudgeOfWeek');
              }
            },
          ),
          title: const Text('Settings'),
        ),
        body: CalmBackground(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Set up your partner profile first.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.goNamed('partnerProfile'),
                  child: const Text('Create Profile'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.goNamed('nudgeOfWeek');
            }
          },
        ),
        title: const Text('Settings'),
      ), 
      body: CalmBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Partner Profile', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              // Love language summary
              Builder(builder: (context) {
                final primary = partner.loveLanguagePrimary;
                final secondary = partner.loveLanguageSecondary;
                final hasAny =
                    primary != null || secondary != null ||
                    partner.qualityTime != null ||
                    partner.wordsOfAffirmation != null ||
                    partner.actsOfService != null ||
                    partner.physicalTouch != null ||
                    partner.receivingGifts != null;

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
                      return Theme.of(context).colorScheme.primary;
                  }
                }

                Widget chip(String label) {
                  final c = colorFor(label);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c),
                    ),
                    child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c)),
                  );
                }

                // Build normalized percentages (sum ≈ 100) like teaser
                final ratings = <String, int>{
                  'Quality Time': (partner.qualityTime ?? 0).clamp(0, 5),
                  'Words of Affirmation': (partner.wordsOfAffirmation ?? 0).clamp(0, 5),
                  'Acts of Service': (partner.actsOfService ?? 0).clamp(0, 5),
                  'Physical Touch': (partner.physicalTouch ?? 0).clamp(0, 5),
                  'Receiving Gifts': (partner.receivingGifts ?? 0).clamp(0, 5),
                };
                final sum = ratings.values.fold<int>(0, (a, b) => a + b);
                int percentFor(String label) => sum > 0 ? ((ratings[label]! / sum) * 100).round() : 0;

                Widget ratingRow(String label, int? value) {
                  final pct = percentFor(label);
                  final c = colorFor(label);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Expanded(child: Text(label)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12)),
                        child: Text('$pct%', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
                      )
                    ]),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: hasAny
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Love language results', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              Wrap(spacing: 8, runSpacing: 8, children: [
                                if (primary != null) chip('Primary: $primary'),
                                if (secondary != null) chip('Secondary: $secondary'),
                              ]),
                              const SizedBox(height: 8),
                              ratingRow('Quality Time', partner.qualityTime),
                              ratingRow('Words of Affirmation', partner.wordsOfAffirmation),
                              ratingRow('Acts of Service', partner.actsOfService),
                              ratingRow('Physical Touch', partner.physicalTouch),
                              ratingRow('Receiving Gifts', partner.receivingGifts),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Love language results', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 6),
                              Text('No results yet. Take the quiz to personalize nudges.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.favorite_rounded),
                title: const Text('Retake Love Language Quiz'),
                subtitle: const Text('Update how we tailor nudges'),
                onTap: () => context.goNamed('loveLanguageQuiz'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt_rounded),
                title: const Text('Reset app (debug)'),
                subtitle: const Text('Clear partner, milestones, gestures, premium'),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('partner');
                  await prefs.remove('milestones');
                  await prefs.remove('weekly_gestures');
                  await prefs.remove('is_premium');
                  await ref.read(partnerProvider.notifier).clear();
                  await ref.read(milestonesProvider.notifier).clear();
                  ref.invalidate(weeklyGesturesProvider);
                  await ref.read(premiumProvider.notifier).downgrade();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App data cleared')));
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3066),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextFormField(
                  controller: _favoritesCtrl,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Favorite snacks / treats / stores',
                    hintText: 'e.g., Matcha latte, Trader Joe\'s, dark chocolate',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _budgetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Gift budget (optional)',
                  hintText: 'e.g., \$20/month',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F3066),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final current = ref.read(partnerProvider);
                  if (current == null) return;
                  final updated = Partner(
                    name: current.name,
                    birthday: current.birthday,
                    gender: current.gender,
                    loveLanguagePrimary: current.loveLanguagePrimary,
                    loveLanguageSecondary: current.loveLanguageSecondary,
                    favorites: _favoritesCtrl.text.trim().isEmpty
                        ? null
                        : _favoritesCtrl.text.trim(),
                    dislikes: current.dislikes,
                    budget: _budgetCtrl.text.trim().isEmpty
                        ? null
                        : _budgetCtrl.text.trim(),
                    qualityTime: current.qualityTime,
                    wordsOfAffirmation: current.wordsOfAffirmation,
                    actsOfService: current.actsOfService,
                    physicalTouch: current.physicalTouch,
                    receivingGifts: current.receivingGifts,
                  );
                  await ref.read(partnerProvider.notifier).savePartner(updated);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved')),
                  );
                  context.pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
