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
  String? _gender;
  DateTime? _birthday;
  DateTime? _togetherSince;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    final p = ref.read(partnerProvider);
    if (p != null) {
      _nameController.text = p.name;
      _gender = p.gender;
      _birthday = p.birthday;
      _togetherSince = p.togetherSince;
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
    return Scaffold(
      body: CalmBackground(
        padding: const EdgeInsets.all(16),
        child: _step == 0
            ? _buildIntro(context)
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 560),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tell us about your partner',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'You can edit this later in Settings.',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      ),
                                      const SizedBox(height: 20),
                                      if (_step == 1) ...[
                                        TextFormField(
                                          controller: _nameController,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(labelText: 'Partner name'),
                                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                        ),
                                        const SizedBox(height: 16),
                                        Text('Gender (optional)', style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 8),
                                        DropdownButtonFormField<String>(
                                          value: _gender,
                                          items: const [
                                            DropdownMenuItem(value: 'Woman', child: Text('Woman')),
                                            DropdownMenuItem(value: 'Man', child: Text('Man')),
                                            DropdownMenuItem(value: 'Non-binary', child: Text('Non-binary')),
                                            DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
                                            DropdownMenuItem(value: 'Other', child: Text('Other...')),
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
                                        const SizedBox(height: 20),
                                        _buildDatesSection(context),
                                      ],
                                      const SizedBox(height: 120),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_step == 0) ...[
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: const Color(0xFF695AD3),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  onPressed: () => setState(() => _step = 1),
                  child: const Text('Continue', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your data is private and secure.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ] else ...[
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: const Color(0xFF695AD3),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  onPressed: () async {
                    if (_step == 1) {
                      if (!_formKey.currentState!.validate()) return;
                    }
                    final current = ref.read(partnerProvider);
                    final updated = Partner(
                      name: _nameController.text.trim(),
                      gender: _gender == 'Other'
                          ? (_customGenderController.text.trim().isEmpty ? current?.gender : _customGenderController.text.trim())
                          : (_gender ?? current?.gender),
                      birthday: _birthday ?? current?.birthday,
                      togetherSince: _togetherSince ?? current?.togetherSince,
                      qualityTime: current?.qualityTime,
                      wordsOfAffirmation: current?.wordsOfAffirmation,
                      actsOfService: current?.actsOfService,
                      physicalTouch: current?.physicalTouch,
                      receivingGifts: current?.receivingGifts,
                      favorites: current?.favorites,
                      dislikes: current?.dislikes,
                      budget: current?.budget,
                      loveLanguagePrimary: current?.loveLanguagePrimary,
                      loveLanguageSecondary: current?.loveLanguageSecondary,
                    );
                    await ref.read(partnerProvider.notifier).savePartner(updated);
                    if (!mounted) return;
                    context.goNamed('loveLanguageQuiz');
                  },
                  child: const Text('Continue', style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget infoCard(IconData icon, String title, String subtitle) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            )
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Let's get to know your partner",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700, fontSize: 28),
            ),
            const SizedBox(height: 10),
            Text(
              'This info helps us suggest Little Acts that are perfect for them, making every gesture count.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 16),
            ),
            const SizedBox(height: 20),
            infoCard(Icons.person_rounded, 'Their Name and Gender', 'Helps us tailor suggestions and pronouns for a personal touch.'),
            infoCard(Icons.cake_rounded, 'Their Birthday', 'For timely reminders and special occasion ideas.'),
            infoCard(Icons.favorite_border_rounded, 'Their Love Language', 'The key to unlocking meaningful acts they will appreciate.'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = MaterialLocalizations.of(context);
    String fmt(DateTime? d) => d == null ? 'Select a date' : loc.formatMediumDate(d);

    Future<void> pickBirthday() async {
      final now = DateTime.now();
      final initial = _birthday ?? DateTime(now.year - 25, now.month, now.day);
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: now,
      );
      if (picked != null) setState(() => _birthday = picked);
    }

    Future<void> pickTogetherSince() async {
      final now = DateTime.now();
      final initial = _togetherSince ?? DateTime(now.year - 2, now.month, now.day);
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1990),
        lastDate: now,
      );
      if (picked != null) setState(() => _togetherSince = picked);
    }

    Widget dateField({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: value == 'Select a date' ? cs.primary : cs.onSurface,
                          ),
                    ),
                  ),
                  Icon(icon, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        dateField(
          label: 'Their Birthday',
          value: fmt(_birthday),
          icon: Icons.calendar_today_rounded,
          onTap: pickBirthday,
        ),
        const SizedBox(height: 16),
        dateField(
          label: 'Together Since',
          value: fmt(_togetherSince),
          icon: Icons.event_rounded,
          onTap: pickTogetherSince,
        ),
      ],
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
