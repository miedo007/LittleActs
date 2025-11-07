import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:nudge/models/partner.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/calm_background.dart';
import 'package:nudge/shared/style/palette.dart';

class PartnerProfileScreen extends ConsumerStatefulWidget {
  const PartnerProfileScreen({super.key});
  @override
  ConsumerState<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends ConsumerState<PartnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final _customGenderController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _gender;
  DateTime? _birthday;
  DateTime? _togetherSince;
  int _step = 0;
  bool _birthdayMissing = false;
  bool _togetherSinceMissing = false;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final p = ref.read(partnerProvider);
    if (p != null) {
      _nameController.text = p.name;
      _gender = p.gender;
      _birthday = p.birthday;
      _togetherSince = p.togetherSince;
      _photoPath = p.photoPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customGenderController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
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
                                        _photoPicker(context),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: _nameController,
                                          focusNode: _nameFocus,
                                          textInputAction: TextInputAction.next,
                                          textCapitalization: TextCapitalization.words,
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
                    backgroundColor: AppColors.button,
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
                    backgroundColor: AppColors.button,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  onPressed: () async {
                    if (_step == 1) {
                      if (!_formKey.currentState!.validate()) return;
                      if (_birthday == null || _togetherSince == null) {
                        setState(() {
                          _birthdayMissing = _birthday == null;
                          _togetherSinceMissing = _togetherSince == null;
                        });
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add their birthday and when you started dating.')),
                        );
                        return;
                      }
                    }
                    final current = ref.read(partnerProvider);
                    final needsQuiz = current?.loveLanguagePrimary == null;
                    final updated = Partner(
                      name: _nameController.text.trim(),
                      gender: _gender == 'Other'
                          ? (_customGenderController.text.trim().isEmpty ? current?.gender : _customGenderController.text.trim())
                          : (_gender ?? current?.gender),
                      birthday: _birthday ?? current?.birthday,
                      togetherSince: _togetherSince ?? current?.togetherSince,
                      photoPath: _photoPath ?? current?.photoPath,
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
                      notificationOptIn: current?.notificationOptIn ?? false,
                    );
                    await ref.read(partnerProvider.notifier).savePartner(updated);
                    if (!mounted) return;
                    if (needsQuiz) {
                      context.goNamed('loveLanguageQuiz');
                    } else {
                      Navigator.of(context).maybePop();
                    }
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
    _nameFocus.unfocus();
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
        _birthdayMissing = false;
      });
    }
  }

    Future<void> pickTogetherSince() async {
      final now = DateTime.now();
      final initial = _togetherSince ?? DateTime(now.year - 2, now.month, now.day);
      _nameFocus.unfocus();
      FocusScope.of(context).unfocus();
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1990),
        lastDate: now,
      );
    if (picked != null) {
      setState(() {
        _togetherSince = picked;
        _togetherSinceMissing = false;
      });
    }
  }

  Widget dateField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    String? error,
  }) {
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
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(error, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent)),
          ],
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
          error: _birthdayMissing ? 'Birthday is required' : null,
        ),
        const SizedBox(height: 16),
        dateField(
          label: 'Together Since',
          value: fmt(_togetherSince),
          icon: Icons.event_rounded,
          onTap: pickTogetherSince,
          error: _togetherSinceMissing ? 'Dating start date is required' : null,
        ),
      ],
    );
  }

  Widget _photoPicker(BuildContext context) {
    final hasPhoto = _photoPath != null &&
        _photoPath!.isNotEmpty &&
        File(_photoPath!).existsSync();
    return Column(
      children: [
        GestureDetector(
          onTap: _pickPhoto,
          child: CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.frameOutline.withOpacity(0.3),
            backgroundImage: hasPhoto ? FileImage(File(_photoPath!)) : null,
            child: hasPhoto
                ? null
                : const Icon(Icons.camera_alt_rounded,
                    size: 32, color: AppColors.icon),
          ),
        ),
        TextButton(
          onPressed: _pickPhoto,
          child: Text(hasPhoto ? 'Change photo' : 'Add photo'),
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final newPath =
        '${dir.path}/partner_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await File(picked.path).copy(newPath);
      if (!mounted) return;
      setState(() {
        _deleteLocalPhoto(_photoPath);
        _photoPath = newPath;
      });
    } catch (_) {}
  }

  void _deleteLocalPhoto(String? path) {
    if (path == null) return;
    try {
      File(path).deleteSync();
    } catch (_) {}
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
