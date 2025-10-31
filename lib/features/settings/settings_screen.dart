import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/models/partner.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/calm_background.dart';

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
        appBar: AppBar(title: const Text('Settings')),
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
      appBar: AppBar(title: const Text('Settings')), 
      body: CalmBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _favoritesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Favorite snacks / treats / stores',
                  hintText: 'e.g., Matcha latte, Trader Joe\'s, dark chocolate',
                ),
                maxLines: 2,
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
                onPressed: () async {
                  final current = ref.read(partnerProvider);
                  if (current == null) return;
                  final updated = Partner(
                    name: current.name,
                    birthday: current.birthday,
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
