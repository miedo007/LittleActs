import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:nudge/models/partner.dart';

import 'package:nudge/shared/widgets/Providers/partner_provider.dart';



class PartnerProfileScreen extends ConsumerStatefulWidget {

  const PartnerProfileScreen({super.key});

  @override

  ConsumerState<PartnerProfileScreen> createState() => _PartnerProfileScreenState();

}



class _PartnerProfileScreenState extends ConsumerState<PartnerProfileScreen> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();



  int _qTime = 3;

  int _words = 3;

  int _service = 3;

  int _touch = 3;

  int _gifts = 3;

  int _step = 0; // 0 intro, 1 name, 2..6 ratings



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

    }

  }



  @override

  Widget build(BuildContext context) {

    { final progress = (_step.clamp(0,6))/6.0; return Scaffold(appBar: AppBar(title: Text(_step == 0 ? 'Personalize Nudges' : _stepTitle(_step)), bottom: PreferredSize(preferredSize: const Size.fromHeight(4), child: LinearProgressIndicator(value: progress),),), body: Padding(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: _buildStep(context))), ); }

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

      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ const SizedBox(height: 24),

        _HeroIcon(icon: Icons.favorite_rounded),

        const SizedBox(height: 12),

        Text('A few quick questions', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 8),

        Text('We use these to tailor weekly nudges and milestone ideas to your partner\'s preferences. You can edit them anytime in Settings.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),

        const SizedBox(height: 16),

        const _Bullet(text: 'Name — for a more personal touch'),

        const _Bullet(text: 'Love language ratings — guide the kind of nudges you get'),

        const _Bullet(text: 'Short and simple — less than 1 minute'),

        const Spacer(),

        FilledButton(onPressed: () => setState(() => _step = 1), child: const Text('Get started')),

      ]);

    }



    if (_step == 1) {

      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ const SizedBox(height: 24),

        Text('What is your partner\'s name?', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 12),

        TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Partner Name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),

        const Spacer(),

        FilledButton(onPressed: () { if (_formKey.currentState!.validate()) setState(() => _step = 2); }, child: const Text('Next')),

      ]);

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



    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ const SizedBox(height: 24),

      Text(title, style: Theme.of(context).textTheme.titleLarge),

      const SizedBox(height: 10),

      _HeroIcon(icon: _iconForStep(_step)),

      const SizedBox(height: 12),

      Text(desc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),

      const SizedBox(height: 16),

      _RatingTile(label: title, value: value, onChanged: setter),

      const SizedBox(height: 8),

      _ExamplesChips(items: _examplesForStep(_step)),

      const Spacer(),

      Row(children: [

        OutlinedButton(onPressed: () => setState(() => _step = (_step - 1).clamp(0, 6)), child: const Text('Back')),

        const SizedBox(width: 12),

        Expanded(child: FilledButton(onPressed: () async {

          if (_step < 6) { setState(() => _step++); return; }

          if (_nameController.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add partner name'))); setState(() => _step = 1); return; }

          final partner = Partner(name: _nameController.text.trim(), qualityTime: _qTime, wordsOfAffirmation: _words, actsOfService: _service, physicalTouch: _touch, receivingGifts: _gifts);

          await ref.read(partnerProvider.notifier).savePartner(partner);

          if (!context.mounted) return; context.goNamed('milestonePlanner');

        }, child: Text(_step < 6 ? 'Next' : 'Finish')))

      ])

    ]);

  }



  IconData _iconForStep(int s) {

    switch (s) {

      case 2: return Icons.schedule_rounded;

      case 3: return Icons.chat_bubble_rounded;

      case 4: return Icons.handyman_rounded;

      case 5: return Icons.favorite_rounded;

      case 6: return Icons.card_giftcard_rounded;

      default: return Icons.favorite_rounded;

    }

  }



  List<String> _examplesForStep(int s) {

    switch (s) {

      case 2: return ['Phone-free walk','Coffee chat','Plan a short date'];

      case 3: return ['Leave a note','Supportive text','Genuine compliment'];

      case 4: return ['Do a chore','Prep breakfast','Tidy their space'];

      case 5: return ['20-sec hug','Hold hands','Shoulder massage'];

      case 6: return ['Favorite snack','Small flower','Thoughtful surprise'];

      default: return const [];

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

      width: 96, height: 96,

      decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color.alphaBlend(cs.primary.withValues(alpha: 0.18), cs.surface), cs.primary], begin: Alignment.topCenter, end: Alignment.bottomCenter), boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 18)]),

      child: Icon(icon, color: cs.onPrimary, size: 36),

    );

  }

}

class _Bullet extends StatelessWidget {

  final String text;

  const _Bullet({required this.text});

  @override

  Widget build(BuildContext context) {

    final cs = Theme.of(context).colorScheme;

    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Icon(Icons.check_circle, size: 18, color: cs.primary), const SizedBox(width: 8), Expanded(child: Text(text))]));

  }

}

class _ExamplesChips extends StatelessWidget {

  final List<String> items;

  const _ExamplesChips({required this.items});

  @override

  Widget build(BuildContext context) {

    final cs = Theme.of(context).colorScheme;

    return Wrap(spacing: 8, runSpacing: 8, children: [for (final t in items) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Color.alphaBlend(cs.primary.withValues(alpha: 0.06), cs.surface), borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.outlineVariant)), child: Text(t))]);

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

    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.titleSmall), const SizedBox(height: 4), Row(children: [Expanded(child: Slider(min: 0, max: 5, divisions: 5, value: value.toDouble(), label: 'value', onChanged: (v) => onChanged(v.round()))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(8)), child: Text('value', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onPrimary)))])])));

  }

}








