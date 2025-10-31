import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/models/partner.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:go_router/go_router.dart';

class PartnerProfileScreen extends ConsumerStatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  ConsumerState<PartnerProfileScreen> createState() =>
      _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends ConsumerState<PartnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int _qTime = 3;
  int _words = 3;
  int _service = 3;
  int _touch = 3;
  int _gifts = 3;

  @override
  void initState() {
    super.initState();
    final partner = ref.read(partnerProvider);
    if (partner != null) {
      _nameController.text = partner.name;
      _qTime = partner.qualityTime ?? _qTime;
      _words = partner.wordsOfAffirmation ?? _words;
      _service = partner.actsOfService ?? _service;
      _touch = partner.physicalTouch ?? _touch;
      _gifts = partner.receivingGifts ?? _gifts;
      // Back-compat: boost primary if present
      final primary = partner.loveLanguagePrimary?.toLowerCase() ?? '';
      void bump(String key) {
        switch (key) {
          case 'quality time':
          case 'time':
            _qTime = 5;
            break;
          case 'words of affirmation':
          case 'words':
            _words = 5;
            break;
          case 'acts of service':
          case 'service':
            _service = 5;
            break;
          case 'physical touch':
          case 'touch':
            _touch = 5;
            break;
          case 'receiving gifts':
          case 'gifts':
            _gifts = 5;
            break;
        }
      }
      bump(primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Partner Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _RatingTile(
                label: 'Quality Time',
                value: _qTime,
                onChanged: (v) => setState(() => _qTime = v),
              ),
              _RatingTile(
                label: 'Words of Affirmation',
                value: _words,
                onChanged: (v) => setState(() => _words = v),
              ),
              _RatingTile(
                label: 'Acts of Service',
                value: _service,
                onChanged: (v) => setState(() => _service = v),
              ),
              _RatingTile(
                label: 'Physical Touch',
                value: _touch,
                onChanged: (v) => setState(() => _touch = v),
              ),
              _RatingTile(
                label: 'Receiving Gifts',
                value: _gifts,
                onChanged: (v) => setState(() => _gifts = v),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final partner = Partner(
                      name: _nameController.text.trim(),
                      qualityTime: _qTime,
                      wordsOfAffirmation: _words,
                      actsOfService: _service,
                      physicalTouch: _touch,
                      receivingGifts: _gifts,
                    );
                    await ref
                        .read(partnerProvider.notifier)
                        .savePartner(partner);
                    if (!context.mounted) return;
                    context.goNamed('milestonePlanner');
                  }
                },
                child: const Text('Next: Milestones'),
              ),
            ],
          ),
        ),
      ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 5,
                    divisions: 5,
                    value: value.toDouble(),
                    label: '$value',
                    onChanged: (v) => onChanged(v.round()),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$value', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onPrimary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
