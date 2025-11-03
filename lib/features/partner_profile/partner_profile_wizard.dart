import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nudge/models/partner.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/calm_background.dart';

class PartnerProfileScreen extends ConsumerStatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  ConsumerState<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends ConsumerState<PartnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _customGenderController = TextEditingController();

  String? _gender; // selected gender (optional)

  int _qTime = 3;
  int _words = 3;
  int _service = 3;
  int _touch = 3;
  int _gifts = 3;

  int _step = 0; // 0 intro, 1 name+gender, 2..6 ratings

  @override
  void initState() {
    super.initState();
    final partner = ref.read(partnerProvider);
    if (partner != null) {
      _nameController.text = partner.name;
      _gender = partner.gender;
      _qTime = partner.qualityTime ?? _qTime;
      _words = partner.wordsOfAffirmation ?? _words;
      _service = partner.actsOfService ?? _service;
      _touch = partner.physicalTouch ?? _touch;
      _gifts = partner.receivingGifts ?? _gifts;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customGenderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step.clamp(0, 6)) / 6.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'Personalize Nudges' : _stepTitle(_step)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: CalmBackground(
        padding: const EdgeInsets.all(16),
        child: Form(key: _formKey, child: _buildStep(context)),
      ),
    );
  }

  String _stepTitle(int s) {
    switch (s) {
      case 1:
        return 'Your Partner';
      case 2:
        return 'Quality Time';
      case 3:
        return 'Words of Affirmation';
      case 4:
        return 'Acts of Service';
      case 5:
        return 'Physical Touch';
      case 6:
        return 'Receiving Gifts';
      default:
        return 'Personalize Nudges';
    }
  }

  Widget _buildStep(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_step == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const _HeroIcon(icon: Icons.favorite_rounded),
          const SizedBox(height: 12),
          Text('A few quick questions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "We use these to tailor weekly nudges and milestone ideas to your partner's preferences. You can edit them anytime in Settings.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          const _Bullet(text: 'Name & gender (optional)'),
          const _Bullet(text: 'Love language ratings for guidance'),
          const _Bullet(text: 'Short and simple — under a minute'),
          const Spacer(),
          FilledButton(onPressed: () => setState(() => _step = 1), child: const Text('Get started')),
        ],
      );
    }

    if (_step == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text("What is your partner's name?", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Partner name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          Text('Gender (optional)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            items: const [
              DropdownMenuItem(value: 'Woman', child: Text('Woman')),
              DropdownMenuItem(value: 'Man', child: Text('Man')),
              DropdownMenuItem(value: 'Non-binary', child: Text('Non-binary')),
              DropdownMenuItem(value: 'Trans woman', child: Text('Trans woman')),
              DropdownMenuItem(value: 'Trans man', child: Text('Trans man')),
              DropdownMenuItem(value: 'Genderqueer', child: Text('Genderqueer')),
              DropdownMenuItem(value: 'Agender', child: Text('Agender')),
              DropdownMenuItem(value: 'Genderfluid', child: Text('Genderfluid')),
              DropdownMenuItem(value: 'Two-Spirit', child: Text('Two-Spirit')),
              DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
              DropdownMenuItem(value: 'Other', child: Text('Other…')),
            ],
            onChanged: (v) => setState(() => _gender = v),
            decoration: const InputDecoration(labelText: 'Select gender'),
          ),
          if (_gender == 'Other') ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _customGenderController,
              decoration: const InputDecoration(labelText: 'Enter gender'),
            ),
          ],
          const Spacer(),
          FilledButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              final current = ref.read(partnerProvider);
              final updated = Partner(
                name: _nameController.text.trim(),
                gender: _gender == 'Other'
                    ? (_customGenderController.text.trim().isEmpty
                        ? current?.gender
                        : _customGenderController.text.trim())
                    : (_gender ?? current?.gender),
                birthday: current?.birthday,
                favorites: current?.favorites,
                dislikes: current?.dislikes,
                budget: current?.budget,
                qualityTime: current?.qualityTime,
                wordsOfAffirmation: current?.wordsOfAffirmation,
                actsOfService: current?.actsOfService,
                physicalTouch: current?.physicalTouch,
                receivingGifts: current?.receivingGifts,
                loveLanguagePrimary: current?.loveLanguagePrimary,
                loveLanguageSecondary: current?.loveLanguageSecondary,
              );
              await ref.read(partnerProvider.notifier).savePartner(updated);
              if (!mounted) return;
              context.goNamed('loveLanguageQuiz');
            },
            child: const Text('Next'),
          ),
        ],
      );
    }

    final title = _stepTitle(_step);
    String desc;
    int value;
    ValueChanged<int> setter;

    switch (_step) {
      case 2:
        desc = 'Quality time means focused attention without distractions — shared activities, conversations, or simple presence.';
        value = _qTime;
        setter = (v) => setState(() => _qTime = v);
        break;
      case 3:
        desc = 'Words of affirmation are sincere compliments, appreciation, and encouragement — spoken or written.';
        value = _words;
        setter = (v) => setState(() => _words = v);
        break;
      case 4:
        desc = 'Acts of service are helpful gestures that reduce friction — doing chores, preparing something, or lending a hand.';
        value = _service;
        setter = (v) => setState(() => _service = v);
        break;
      case 5:
        desc = 'Physical touch is affection through contact — hugs, cuddles, hand-holding, or a gentle massage.';
        value = _touch;
        setter = (v) => setState(() => _touch = v);
        break;
      case 6:
      default:
        desc = 'Receiving gifts are thoughtful tokens — from small treats to meaningful surprises that show you care.';
        value = _gifts;
        setter = (v) => setState(() => _gifts = v);
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        _HeroIcon(icon: _iconForStep(_step)),
        const SizedBox(height: 12),
        Text(
          desc,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        _RatingTile(label: title, value: value, onChanged: setter),
        const SizedBox(height: 8),
        _ExamplesChips(items: _examplesForStep(_step)),
        const Spacer(),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _step = (_step - 1).clamp(0, 6)),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  if (_step < 6) {
                    setState(() => _step++);
                    return;
                  }

                  if (_nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please add partner name')),
                    );
                    setState(() => _step = 1);
                    return;
                  }

                  final chosenGender = _gender == 'Other'
                      ? (_customGenderController.text.trim().isEmpty
                          ? null
                          : _customGenderController.text.trim())
                      : _gender;

                  final partner = Partner(
                    name: _nameController.text.trim(),
                    gender: chosenGender,
                    qualityTime: _qTime,
                    wordsOfAffirmation: _words,
                    actsOfService: _service,
                    physicalTouch: _touch,
                    receivingGifts: _gifts,
                  );

                  await ref.read(partnerProvider.notifier).savePartner(partner);
                  if (!context.mounted) return;
                  context.goNamed('milestonePlanner');
                },
                child: Text(_step < 6 ? 'Next' : 'Finish'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _iconForStep(int s) {
    switch (s) {
      case 2:
        return Icons.schedule_rounded;
      case 3:
        return Icons.chat_bubble_rounded;
      case 4:
        return Icons.handyman_rounded;
      case 5:
        return Icons.favorite_rounded;
      case 6:
        return Icons.card_giftcard_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }

  List<String> _examplesForStep(int s) {
    switch (s) {
      case 2:
        return ['Phone-free walk', 'Coffee chat', 'Plan a short date'];
      case 3:
        return ['Leave a note', 'Supportive text', 'Genuine compliment'];
      case 4:
        return ['Do a chore', 'Prep breakfast', 'Tidy their space'];
      case 5:
        return ['20-sec hug', 'Hold hands', 'Shoulder massage'];
      case 6:
        return ['Favorite snack', 'Small flower', 'Thoughtful surprise'];
      default:
        return const [];
    }
  }
}

class _HeroIcon extends StatelessWidget {
  final IconData icon;
  const _HeroIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.alphaBlend(cs.primary.withValues(alpha: 0.18), cs.surface),
            cs.primary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 18),
        ],
      ),
      child: Icon(icon, color: cs.onPrimary, size: 36),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF53D476);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ExamplesChips extends StatelessWidget {
  final List<String> items;
  const _ExamplesChips({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Color.alphaBlend(cs.primary.withValues(alpha: 0.06), cs.surface),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Text(t),
          ),
      ],
    );
  }
}

class _RatingTile extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _RatingTile({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const tileBlue = Color(0xFF0F3066);
    const green = Color(0xFF53D476);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: tileBlue,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white24,
                    ),
                  child: Slider(
                      min: 0,
                      max: 5,
                      divisions: 5,
                      value: value.toDouble(),
                      label: '$value',
                      onChanged: (v) => onChanged(v.round()),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: green.withOpacity(0.25), blurRadius: 10),
                    ],
                  ),
                  child: Text('$value', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
