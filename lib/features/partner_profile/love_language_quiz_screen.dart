import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nudge/models/partner.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/calm_background.dart';

class LoveLanguageQuizScreen extends ConsumerStatefulWidget {
  const LoveLanguageQuizScreen({super.key});

  @override
  ConsumerState<LoveLanguageQuizScreen> createState() => _LoveLanguageQuizScreenState();
}

class _LoveLanguageQuizScreenState extends ConsumerState<LoveLanguageQuizScreen> {
  int index = 0;
  bool _finalizing = false;
  final Map<String, int> scores = {
    'Words of Affirmation': 0,
    'Acts of Service': 0,
    'Physical Touch': 0,
    'Receiving Gifts': 0,
    'Quality Time': 0,
  };

  late final List<_Q> _questions = [
    _Q('Which makes your partner happier?', 'When you say something kind or encouraging.', 'When you do something that makes their day easier.', 'Words of Affirmation', 'Acts of Service'),
    _Q('What seems to mean more to them?', 'A warm hug or holding hands.', 'Receiving a thoughtful little gift.', 'Physical Touch', 'Receiving Gifts'),
    _Q('If you could only do one, which would they prefer?', 'Spending uninterrupted time together.', 'Hearing genuine appreciation for what they do.', 'Quality Time', 'Words of Affirmation'),
    _Q('What melts their stress faster?', 'You making them coffee or dinner.', 'You sitting with them and truly listening.', 'Acts of Service', 'Quality Time'),
    _Q('When they’re having a tough day…', 'You reach out to hold them.', 'You send a text saying how proud you are of them.', 'Physical Touch', 'Words of Affirmation'),
    _Q('What do they remember the most later?', 'The thoughtful little surprises you gave them.', 'The moments when you stopped everything just to be with them.', 'Receiving Gifts', 'Quality Time'),
    _Q('Which one feels more “them”?', 'They love small tokens or mementos.', 'They light up when you help them with tasks.', 'Receiving Gifts', 'Acts of Service'),
    _Q('If you skip it for a while, what do they miss most?', 'Physical affection.', 'Compliments and reassurance.', 'Physical Touch', 'Words of Affirmation'),
    _Q('When you want to make them feel special, what works best?', 'Planning a cozy date or activity together.', 'Doing a favor or helping with something they hate doing.', 'Quality Time', 'Acts of Service'),
    _Q('What do they notice first?', 'That you told them how much they mean to you.', 'That you made their life easier without them asking.', 'Words of Affirmation', 'Acts of Service'),
    // 11-20 (additional)
    _Q('When you surprise your partner, what feels more special to them?', 'Leaving a heartfelt note where they’ll find it.', 'Planning an evening just for the two of you.', 'Words of Affirmation', 'Quality Time'),
    _Q('What seems to calm them fastest?', 'You sitting beside them and holding their hand.', 'You taking care of something they were stressing about.', 'Physical Touch', 'Acts of Service'),
    _Q('If you want to cheer them up, what usually works?', 'Giving them a small treat or gift they love.', 'Telling them how much they mean to you.', 'Receiving Gifts', 'Words of Affirmation'),
    _Q('What does your partner tend to notice first?', 'That you’ve tidied, fixed, or handled something for them.', 'That you made time to be together, even briefly.', 'Acts of Service', 'Quality Time'),
    _Q('What makes them feel most secure in the relationship?', 'Regular physical affection and closeness.', 'Hearing you express love and appreciation often.', 'Physical Touch', 'Words of Affirmation'),
    _Q('When they talk about favorite memories, what do they mention?', 'Trips, dates, or shared experiences.', 'Surprises or gifts you gave them.', 'Quality Time', 'Receiving Gifts'),
    _Q('Which gesture gets the biggest smile?', 'Doing an errand or task they dislike.', 'Giving them a spontaneous hug or kiss.', 'Acts of Service', 'Physical Touch'),
    _Q('When they tell others about you, what do they highlight?', 'How thoughtful you are with small surprises.', 'How supported they feel when you help or show up.', 'Receiving Gifts', 'Acts of Service'),
    _Q('Which makes them feel more connected?', 'Having deep conversations together.', 'Getting sweet texts or compliments from you.', 'Quality Time', 'Words of Affirmation'),
    _Q('If you’ve been busy or apart for a while, what do they crave first?', 'Physical closeness — a hug, touch, or cuddle.', 'A meaningful talk or quality time together.', 'Physical Touch', 'Quality Time'),
  ];

  void _answer(bool chooseA) {
    final q = _questions[index];
    final key = chooseA ? q.langA : q.langB;
    scores[key] = (scores[key] ?? 0) + 1;
    if (index < _questions.length - 1) {
      setState(() => index++);
    } else {
      // Finalize: save and navigate to teaser (no full results screen)
      setState(() => _finalizing = true);
      _saveResults(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _questions.length.toDouble();
    return Scaffold(
      appBar: AppBar(title: const Text('Love Language Quiz')),
      body: CalmBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: (index.clamp(0, _questions.length)) / total),
            const SizedBox(height: 16),
            if (!_finalizing)
              _QuestionCard(
                number: (index + 1).clamp(1, _questions.length),
                total: _questions.length,
                q: _questions[index],
                onA: () => _answer(true),
                onB: () => _answer(false),
              )
            else
              const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  Future<void> _saveResults(BuildContext context) async {
    final current = ref.read(partnerProvider);
    // Normalize to 0..5 scale
    final maxCount = scores.values.fold<int>(0, (a, b) => b > a ? b : a);
    int toRating(String key) {
      if (maxCount == 0) return 0;
      final v = scores[key] ?? 0;
      final r = ((v / maxCount) * 5).round();
      return r;
    }
    final updated = Partner(
      name: current?.name ?? '',
      birthday: current?.birthday,
      gender: current?.gender,
      loveLanguagePrimary: _topTwo(scores).isNotEmpty ? _topTwo(scores)[0] : null,
      loveLanguageSecondary: _topTwo(scores).length > 1 ? _topTwo(scores)[1] : null,
      favorites: current?.favorites,
      dislikes: current?.dislikes,
      budget: current?.budget,
      qualityTime: toRating('Quality Time'),
      wordsOfAffirmation: toRating('Words of Affirmation'),
      actsOfService: toRating('Acts of Service'),
      physicalTouch: toRating('Physical Touch'),
      receivingGifts: toRating('Receiving Gifts'),
    );
    await ref.read(partnerProvider.notifier).savePartner(updated);
    if (!mounted) return;
    context.goNamed('quizTeaser');
  }

  List<String> _topTwo(Map<String, int> map) {
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [for (final e in sorted.take(2)) e.key];
  }
}

class _Q {
  final String title;
  final String a;
  final String b;
  final String langA;
  final String langB;
  _Q(this.title, this.a, this.b, this.langA, this.langB);
}

class _QuestionCard extends StatelessWidget {
  final int number;
  final int total;
  final _Q q;
  final VoidCallback onA;
  final VoidCallback onB;
  const _QuestionCard({required this.number, required this.total, required this.q, required this.onA, required this.onB});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question $number of $total', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(q.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _ChoiceTile(label: 'A', text: q.a, onTap: onA),
          const SizedBox(height: 12),
          _ChoiceTile(label: 'B', text: q.b, onTap: onB),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback onTap;
  const _ChoiceTile({required this.label, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onPrimary)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final Map<String, int> scores;
  final int totalQuestions;
  final Future<void> Function(BuildContext) onSave;
  const _Results({required this.scores, required this.totalQuestions, required this.onSave});

  static const Map<String, Color> _langColors = {
    'Words of Affirmation': Color(0xFF6C63FF),
    'Acts of Service': Color(0xFF00B894),
    'Physical Touch': Color(0xFFFF7675),
    'Receiving Gifts': Color(0xFFFDCB6E),
    'Quality Time': Color(0xFF0984E3),
  };

  static const Map<String, String> _langDescriptions = {
    'Words of Affirmation':
        'They feel most loved when they hear it. Verbal appreciation, encouragement, and kind words reassure them that they’re valued and seen.',
    'Acts of Service':
        'Actions speak louder than words for them. They feel cared for when you make their life easier — through help, effort, or small thoughtful tasks.',
    'Quality Time':
        'They feel loved when you give them your full attention. What matters most is being truly present, not multitasking — shared moments mean everything.',
    'Receiving Gifts':
        'They feel appreciated when love takes a tangible form. A small, thoughtful gift says “I was thinking of you” and becomes a symbol of care.',
    'Physical Touch':
        'They feel connected through closeness. Holding hands, a hug, or any gentle touch communicates warmth and safety beyond words.',
  };

  @override
  Widget build(BuildContext context) {
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your partner’s love language ranking', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (int i = 0; i < sorted.length; i++) ...[
            _ResultRow(
              rank: i + 1,
              label: sorted[i].key,
              percent: totalQuestions == 0 ? 0 : ((sorted[i].value / totalQuestions) * 100).round(),
              color: _langColors[sorted[i].key] ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 4, bottom: 10),
              child: Text(
                _langDescriptions[sorted[i].key] ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
            ),
          ],
          const Spacer(),
          FilledButton(
            onPressed: () => onSave(context),
            child: const Text('Save & Continue'),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final int rank;
  final String label;
  final int percent; // 0..100
  final Color color;
  const _ResultRow({required this.rank, required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)),
          alignment: Alignment.center,
          child: Text('$rank', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Text('$percent%', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}

