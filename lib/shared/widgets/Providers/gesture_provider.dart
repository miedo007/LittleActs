import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nudge/models/weekly_gesture.dart';
import 'package:nudge/models/partner.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/Services/notification_service.dart';

// Central catalog: descriptions by title for all categories
const Map<String, String> _gestureDescriptions = {
  // Words of Affirmation
  'Morning Compliment': 'Start their day with kind words about something you love about them.',
  'Random Message': 'Send a quick “thinking of you” text out of the blue.',
  'Written Note': 'Slip a small, sincere note where they will find it later.',
  'Voice Memo': 'Record a short voice note saying what you admire about them.',
  'Public Praise': 'Compliment them in front of others to show pride and appreciation.',
  'Gratitude List': 'Tell them three small things you appreciated about them this week.',
  'Future Love Letter': 'Write what you’re excited to experience together soon.',
  'Morning Text Habit': 'Send one encouraging line to start their day gently.',
  'Affirm Their Strengths': 'Remind them of what they’re great at, especially if they doubt themselves.',
  'Thank You Moment': 'Thank them for something you usually take for granted.',
  'Compliment Post-It': 'Stick a one-liner like “You make me smile” somewhere unexpected.',
  'Appreciation Recap': 'Before bed, share one thing you appreciated today.',
  'I Love the Way': 'Finish the sentence: “I love the way you…” with something honest.',
  'Mirror Message': 'Write a quick compliment on the bathroom mirror.',
  'Support Text': 'If they have a big day, send a proud, encouraging note.',
  'Daily Highlight': 'Share your favorite part of the day and why they made it better.',
  'Repeat Their Words': 'Echo back something meaningful they shared to show you heard it.',
  'End-of-Day Praise': 'Tell them one thing they handled well today.',
  'Love Playlist Message': 'Send a song that says what you feel.',
  'Heartfelt I Miss You': 'Say you miss them—keep the connection soft and tender.',

  // Acts of Service
  'Morning Coffee Surprise': 'Bring their favorite coffee in bed just the way they like it.',
  'Chore Swap': 'Do one of their least-favorite chores without being asked.',
  'Car Ready': 'Warm up or tidy their car before they leave.',
  'Meal Prep Magic': 'Cook dinner or prep lunch to make life easier.',
  'Laundry Help': 'Fold their clothes before they even ask.',
  'Grocery Grab': 'Pick up a favorite snack or ingredient on your way home.',
  'Tech Support': 'Fix or update a small tech issue they’ve been ignoring.',
  'Quiet Mornings': 'Handle the morning routine so they can sleep in a bit.',
  'Refill & Restock': 'Top up a favorite item before it runs out.',
  'Errand Hero': 'Run a small errand for them with no questions asked.',
  'Surprise Tidy-Up': 'Clean a small space they use daily.',
  'Plan Dinner': 'Pick a place, book it, and say “Be ready at 7.”',
  'Mini Maintenance': 'Fix one small thing around the house.',
  'Warm Welcome': 'Set the vibe—light a candle or play soft music.',
  'Pack a Snack': 'Slip a little treat into their bag or lunch.',
  'Morning Reminder': 'Lay out what they need for a smoother start.',
  'Take the Lead': 'Handle a shared task you usually avoid.',
  'Surprise Grocery Note': 'Add a small surprise to the grocery run.',
  'Care Package': 'Make a tiny comfort box—snack, tea, note.',
  'Bedtime Reset': 'Turn down the bed and make it cozy.',

  // Quality Time
  'Sunset Walk': 'Take a short walk together and leave phones at home.',
  'Device-Free Dinner': 'Eat together with no screens—just conversation.',
  'Shared Playlist Night': 'Trade songs that remind you of moments together.',
  'Memory Jar': 'Start a jar and add a small shared memory note.',
  'Cook Together': 'Make a simple recipe side by side without rushing.',
  'Game Night': 'Play a light game, puzzle, or silly quiz.',
  'Photo Rewind': 'Scroll old photos and relive a favorite time.',
  'At-Home Picnic': 'Blanket, snacks, and drinks—indoors or on the balcony.',
  'Favorite Show Night': 'Watch their favorite show and let them do the commentary.',
  'Cozy Reading': 'Sit together with separate books for shared peace.',
  'Long Drive': 'Go for a no-destination drive with music.',
  'Daily 10-Minute Chat': 'Set aside 10 minutes to talk—no problem-solving.',
  'Dream Planning': 'Imagine a trip or project you’ll do together.',
  'Walk Down Memory Lane': 'Visit a place that matters to you both.',
  'Breakfast Date': 'Start the day together—coffee counts.',
  'Shared Hobby Hour': 'Join something they love for an hour.',
  'Stargazing': 'Spend five quiet minutes looking up together.',
  'Weekend Reset': 'Plan the week calmly, together.',
  'Small Celebration': 'Celebrate a random day with a small treat.',
  'Dance Break': 'Put on a song and dance in the kitchen.',

  // Receiving Gifts
  'Favorite Snack Drop': 'Bring home their go-to snack without warning.',
  'Flower Moment': 'Give one simple flower—sweet and meaningful.',
  'Small Surprise Box': 'Collect three tiny things they love.',
  'Subscription Gesture': 'Gift a month of something they already use.',
  'Matching Keychains': 'Tiny matching items to remind you of each other.',
  'Memory Print': 'Print and frame a favorite photo.',
  'Book Swap': 'Gift a book you think they’ll love with a note.',
  'Sweet Tooth Moment': 'Bring dessert from their favorite spot.',
  'Inside Joke Gift': 'A small token that makes you both laugh.',
  'Comfort Kit': 'Hot drink, cozy socks, and a handwritten note.',
  'Letter + Treat Combo': 'Pair a short note with a small treat.',
  'Playlist Card': 'Share a playlist with a creative QR code.',
  'Desk Drop': 'Leave something small on their workspace to find.',
  'Coffee Treat': 'Surprise them with their usual order.',
  'Tiny Plant Gift': 'A small plant to care for together.',
  'Candle Moment': 'Gift a candle and light it tonight.',
  'Favorite Color Theme': 'Pick a gift in their favorite color.',
  'Souvenir Surprise': 'Bring a token or postcard from a trip.',
  'Personalized Mug': 'A simple mug with a shared saying.',
  'Just Because Gift': 'No reason—just “I saw this and thought of you.”',

  // Physical Touch
  'Long Hug': 'Give a hug that lasts a little longer than usual.',
  'Hand Hold': 'Reach for their hand during a walk or show.',
  'Gentle Touch': 'Brush their hair back or fix a collar with intention.',
  'Slow Dance': 'Turn on soft music and sway together.',
  'Massage Moment': 'Offer a short shoulder or hand massage.',
  'Sit Close': 'Scoot a little closer on the couch.',
  'Forehead Kiss': 'Soft, grounding, and intimate.',
  'Morning Snuggle': 'Stay in bed five more minutes to hold each other.',
  'Touch Check-In': 'Rest your hand on their arm when they talk.',
  'Cuddle Break': 'Pause midday just to be close for a minute.',
  'Movie Night Hold': 'Keep contact during the movie.',
  'Hug Goodbye': 'Never skip it—make it intentional.',
  'Bedtime Hold': 'Fall asleep holding hands or touching feet.',
  'Playful Bump': 'A light, flirty nudge.',
  'Warm Greeting': 'Kiss them when you first see them.',
  'Guided Relax': 'Rub their back while they debrief the day.',
  'Hug From Behind': 'A gentle surprise during a routine moment.',
  'Hand Through Hair': 'A relaxed, affectionate gesture.',
  'Goodbye Kiss': 'Keep the ritual alive, even for short departures.',
  'Touch + Words Combo': 'Hold their hand and share one appreciation.',
};

// Public provider: exposes the current week gesture + history + streak.
final weeklyGesturesProvider =
    StateNotifierProvider<WeeklyGesturesNotifier, List<WeeklyGesture>>(
  (ref) => WeeklyGesturesNotifier(ref),
);

class WeeklyGesturesNotifier extends StateNotifier<List<WeeklyGesture>> {
  WeeklyGesturesNotifier(this._ref) : super(const []) {
    _load().then((_) async {
      await _ensureThisWeekGesture();
      final partner = _ref.read(partnerProvider);
      await NotificationService().scheduleWeeklyNudge(partnerName: (partner?.name.isNotEmpty ?? false) ? partner!.name : 'your partner');
      // Also schedule completion reminder 3 days after the drop (upcoming Sunday)
      final now = DateTime.now();
      final weekday = now.weekday % 7; // Sunday=0
      final daysUntilSunday = (7 - weekday) % 7;
      final drop = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilSunday)).add(const Duration(hours: 9));
      await NotificationService().scheduleActCompletionReminder(drop);
    });
  }

  final Ref _ref;
  static const _key = 'weekly_gestures';

  // ---------- Persistence ----------
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = await compute(_decodeWeeklyGestures, raw);
      state = list;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_key, json);
  }

  // ---------- Helpers ----------
  DateTime _startOfWeek(DateTime d) {
    // Start on SUNDAY
    final weekday = d.weekday % 7; // Sunday => 0
    final start = DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday));
    return DateTime(start.year, start.month, start.day);
  }

  String _weekId(DateTime weekStart) =>
      '${weekStart.year}-W${_weekNumber(weekStart).toString().padLeft(2, '0')}';

  int _weekNumber(DateTime weekStart) {
    final begin = _startOfWeek(DateTime(weekStart.year, 1, 1));
    return (weekStart.difference(begin).inDays ~/ 7) + 1;
  }

  WeeklyGesture currentWeek() {
    final ws = _startOfWeek(DateTime.now());
    final id = _weekId(ws);
    final g = state.firstWhere(
      (g) => g.id == id,
      orElse: () => WeeklyGesture(
        id: id,
        title: '',
        category: '',
        weekStart: ws,
      ),
    );
    if (g.description == null || g.description!.isEmpty) {
      final d = _gestureDescriptions[g.title];
      if (d != null && d.isNotEmpty) {
        return g.copyWith(description: d);
      }
    }
    return g;
  }

  // Limit refreshes per week within same category (max 2)
  Future<bool> refreshWithinSameCategory() async {
    final ws = _startOfWeek(DateTime.now());
    final id = _weekId(ws);
    final prefs = await SharedPreferences.getInstance();
    final key = 'refresh_count_$id';
    final count = prefs.getInt(key) ?? 0;
    if (count >= 2) return false;

    final idx = state.indexWhere((g) => g.id == id);
    if (idx < 0) {
      await _ensureThisWeekGesture();
    }
    final current = currentWeek();
    final cat = current.category;

    WeeklyGesture generateSameCat() {
      final partner = _ref.read(partnerProvider);
      // shift seed to vary suggestion
      final seed = DateTime.now().add(Duration(minutes: count + 1));
      final g = _generateGesture(partner, seed);
      return g.copyWith(id: current.id, weekStart: current.weekStart, category: cat);
    }

    final replacement = generateSameCat();
    state = [
      for (final g in state) if (g.id == id) replacement else g,
    ];
    await _save();
    await prefs.setInt(key, count + 1);
    return true;
  }

  // Expose remaining refreshes for current week (max 2)
  Future<int> refreshesLeftForCurrentWeek() async {
    final ws = _startOfWeek(DateTime.now());
    final id = _weekId(ws);
    final prefs = await SharedPreferences.getInstance();
    final key = 'refresh_count_$id';
    final count = prefs.getInt(key) ?? 0;
    final left = 2 - count;
    return left < 0 ? 0 : left;
  }

  List<WeeklyGesture> completedActs() =>
      state.where((g) => g.completed).toList()
        ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
  Future<void> _ensureThisWeekGesture() async {
    final ws = _startOfWeek(DateTime.now());
    final id = _weekId(ws);
    if (state.any((g) => g.id == id)) return;

    final partner = _ref.read(partnerProvider);
    final suggestion = _generateGesture(partner, ws);
    state = [...state, suggestion];
    await _save();
  }

  // ---------- Generation Rules (with Premium gating) ----------
  WeeklyGesture _generateGesture(Partner? partner, DateTime weekStart) {
    final isPro = _ref.read(premiumProvider);

    final fav = partner?.favorites?.trim();
    // Prefer ratings if present; fallback to primary string.
    String primary;
    final ratings = <String, int>{
      'service': partner?.actsOfService ?? -1,
      'time': partner?.qualityTime ?? -1,
      'words': partner?.wordsOfAffirmation ?? -1,
      'touch': partner?.physicalTouch ?? -1,
      'gift': partner?.receivingGifts ?? -1,
    };
    if (ratings.values.any((v) => v >= 0)) {
      final sorted = ratings.entries
          .where((e) => e.value > 0)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      primary = sorted.isNotEmpty ? sorted.first.key : '';
    } else {
      primary = (partner?.loveLanguagePrimary ?? '').toLowerCase();
    }

    // Titles (20) per category, aligned with description maps below.
    const service = [
      'Morning Coffee Surprise',
      'Chore Swap',
      'Car Ready',
      'Meal Prep Magic',
      'Laundry Help',
      'Grocery Grab',
      'Tech Support',
      'Quiet Mornings',
      'Refill & Restock',
      'Errand Hero',
      'Surprise Tidy-Up',
      'Plan Dinner',
      'Mini Maintenance',
      'Warm Welcome',
      'Pack a Snack',
      'Morning Reminder',
      'Take the Lead',
      'Surprise Grocery Note',
      'Care Package',
      'Bedtime Reset',
    ];
    const time = [
      'Sunset Walk',
      'Device-Free Dinner',
      'Shared Playlist Night',
      'Memory Jar',
      'Cook Together',
      'Game Night',
      'Photo Rewind',
      'At-Home Picnic',
      'Favorite Show Night',
      'Cozy Reading',
      'Long Drive',
      'Daily 10-Minute Chat',
      'Dream Planning',
      'Walk Down Memory Lane',
      'Breakfast Date',
      'Shared Hobby Hour',
      'Stargazing',
      'Weekend Reset',
      'Small Celebration',
      'Dance Break',
    ];
    const words = [
      'Morning Compliment',
      'Random Message',
      'Written Note',
      'Voice Memo',
      'Public Praise',
      'Gratitude List',
      'Future Love Letter',
      'Morning Text Habit',
      'Affirm Their Strengths',
      'Thank You Moment',
      'Compliment Post-It',
      'Appreciation Recap',
      'I Love the Way',
      'Mirror Message',
      'Support Text',
      'Daily Highlight',
      'Repeat Their Words',
      'End-of-Day Praise',
      'Love Playlist Message',
      'Heartfelt I Miss You',
    ];
    final gift = <String>[
      if (isPro && fav != null && fav.isNotEmpty) 'Order their favorite: $fav',
      'Favorite Snack Drop',
      'Flower Moment',
      'Small Surprise Box',
      'Subscription Gesture',
      'Matching Keychains',
      'Memory Print',
      'Book Swap',
      'Sweet Tooth Moment',
      'Inside Joke Gift',
      'Comfort Kit',
      'Letter + Treat Combo',
      'Playlist Card',
      'Desk Drop',
      'Coffee Treat',
      'Tiny Plant Gift',
      'Candle Moment',
      'Favorite Color Theme',
      'Souvenir Surprise',
      'Personalized Mug',
      'Just Because Gift',
    ];
    const touch = [
      'Long Hug',
      'Hand Hold',
      'Gentle Touch',
      'Slow Dance',
      'Massage Moment',
      'Sit Close',
      'Forehead Kiss',
      'Morning Snuggle',
      'Touch Check-In',
      'Cuddle Break',
      'Movie Night Hold',
      'Hug Goodbye',
      'Bedtime Hold',
      'Playful Bump',
      'Warm Greeting',
      'Guided Relax',
      'Hug From Behind',
      'Hand Through Hair',
      'Goodbye Kiss',
      'Touch + Words Combo',
    ];

    // Descriptions per title
    const Map<String, String> desc = {
      // Words of Affirmation
      'Morning Compliment': 'Start their day with kind words about something you love about them.',
      'Random Message': 'Send a quick “thinking of you” text out of the blue.',
      'Written Note': 'Slip a small, sincere note where they will find it later.',
      'Voice Memo': 'Record a short voice note saying what you admire about them.',
      'Public Praise': 'Compliment them in front of others to show pride and appreciation.',
      'Gratitude List': 'Tell them three small things you appreciated about them this week.',
      'Future Love Letter': 'Write what you’re excited to experience together soon.',
      'Morning Text Habit': 'Send one encouraging line to start their day gently.',
      'Affirm Their Strengths': 'Remind them of what they’re great at, especially if they doubt themselves.',
      'Thank You Moment': 'Thank them for something you usually take for granted.',
      'Compliment Post-It': 'Stick a one-liner like “You make me smile” somewhere unexpected.',
      'Appreciation Recap': 'Before bed, share one thing you appreciated today.',
      'I Love the Way': 'Finish the sentence: “I love the way you…” with something honest.',
      'Mirror Message': 'Write a quick compliment on the bathroom mirror.',
      'Support Text': 'If they have a big day, send a proud, encouraging note.',
      'Daily Highlight': 'Share your favorite part of the day and why they made it better.',
      'Repeat Their Words': 'Echo back something meaningful they shared to show you heard it.',
      'End-of-Day Praise': 'Tell them one thing they handled well today.',
      'Love Playlist Message': 'Send a song that says what you feel.',
      'Heartfelt I Miss You': 'Say you miss them—keep the connection soft and tender.',

      // Acts of Service
      'Morning Coffee Surprise': 'Bring their favorite coffee in bed just the way they like it.',
      'Chore Swap': 'Do one of their least-favorite chores without being asked.',
      'Car Ready': 'Warm up or tidy their car before they leave.',
      'Meal Prep Magic': 'Cook dinner or prep lunch to make life easier.',
      'Laundry Help': 'Fold their clothes before they even ask.',
      'Grocery Grab': 'Pick up a favorite snack or ingredient on your way home.',
      'Tech Support': 'Fix or update a small tech issue they’ve been ignoring.',
      'Quiet Mornings': 'Handle the morning routine so they can sleep in a bit.',
      'Refill & Restock': 'Top up a favorite item before it runs out.',
      'Errand Hero': 'Run a small errand for them with no questions asked.',
      'Surprise Tidy-Up': 'Clean a small space they use daily.',
      'Plan Dinner': 'Pick a place, book it, and say “Be ready at 7.”',
      'Mini Maintenance': 'Fix one small thing around the house.',
      'Warm Welcome': 'Set the vibe—light a candle or play soft music.',
      'Pack a Snack': 'Slip a little treat into their bag or lunch.',
      'Morning Reminder': 'Lay out what they need for a smoother start.',
      'Take the Lead': 'Handle a shared task you usually avoid.',
      'Surprise Grocery Note': 'Add a small surprise to the grocery run.',
      'Care Package': 'Make a tiny comfort box—snack, tea, note.',
      'Bedtime Reset': 'Turn down the bed and make it cozy.',

      // Quality Time
      'Sunset Walk': 'Take a short walk together and leave phones at home.',
      'Device-Free Dinner': 'Eat together with no screens—just conversation.',
      'Shared Playlist Night': 'Trade songs that remind you of moments together.',
      'Memory Jar': 'Start a jar and add a small shared memory note.',
      'Cook Together': 'Make a simple recipe side by side without rushing.',
      'Game Night': 'Play a light game, puzzle, or silly quiz.',
      'Photo Rewind': 'Scroll old photos and relive a favorite time.',
      'At-Home Picnic': 'Blanket, snacks, and drinks—indoors or on the balcony.',
      'Favorite Show Night': 'Watch their favorite show and let them do the commentary.',
      'Cozy Reading': 'Sit together with separate books for shared peace.',
      'Long Drive': 'Go for a no-destination drive with music.',
      'Daily 10-Minute Chat': 'Set aside 10 minutes to talk—no problem-solving.',
      'Dream Planning': 'Imagine a trip or project you’ll do together.',
      'Walk Down Memory Lane': 'Visit a place that matters to you both.',
      'Breakfast Date': 'Start the day together—coffee counts.',
      'Shared Hobby Hour': 'Join something they love for an hour.',
      'Stargazing': 'Spend five quiet minutes looking up together.',
      'Weekend Reset': 'Plan the week calmly, together.',
      'Small Celebration': 'Celebrate a random day with a small treat.',
      'Dance Break': 'Put on a song and dance in the kitchen.',

      // Receiving Gifts
      'Favorite Snack Drop': 'Bring home their go-to snack without warning.',
      'Flower Moment': 'Give one simple flower—sweet and meaningful.',
      'Small Surprise Box': 'Collect three tiny things they love.',
      'Subscription Gesture': 'Gift a month of something they already use.',
      'Matching Keychains': 'Tiny matching items to remind you of each other.',
      'Memory Print': 'Print and frame a favorite photo.',
      'Book Swap': 'Gift a book you think they’ll love with a note.',
      'Sweet Tooth Moment': 'Bring dessert from their favorite spot.',
      'Inside Joke Gift': 'A small token that makes you both laugh.',
      'Comfort Kit': 'Hot drink, cozy socks, and a handwritten note.',
      'Letter + Treat Combo': 'Pair a short note with a small treat.',
      'Playlist Card': 'Share a playlist with a creative QR code.',
      'Desk Drop': 'Leave something small on their workspace to find.',
      'Coffee Treat': 'Surprise them with their usual order.',
      'Tiny Plant Gift': 'A small plant to care for together.',
      'Candle Moment': 'Gift a candle and light it tonight.',
      'Favorite Color Theme': 'Pick a gift in their favorite color.',
      'Souvenir Surprise': 'Bring a token or postcard from a trip.',
      'Personalized Mug': 'A simple mug with a shared saying.',
      'Just Because Gift': 'No reason—just “I saw this and thought of you.”',

      // Physical Touch
      'Long Hug': 'Give a hug that lasts a little longer than usual.',
      'Hand Hold': 'Reach for their hand during a walk or show.',
      'Gentle Touch': 'Brush their hair back or fix a collar with intention.',
      'Slow Dance': 'Turn on soft music and sway together.',
      'Massage Moment': 'Offer a short shoulder or hand massage.',
      'Sit Close': 'Scoot a little closer on the couch.',
      'Forehead Kiss': 'Soft, grounding, and intimate.',
      'Morning Snuggle': 'Stay in bed five more minutes to hold each other.',
      'Touch Check-In': 'Rest your hand on their arm when they talk.',
      'Cuddle Break': 'Pause midday just to be close for a minute.',
      'Movie Night Hold': 'Keep contact during the movie.',
      'Hug Goodbye': 'Never skip it—make it intentional.',
      'Bedtime Hold': 'Fall asleep holding hands or touching feet.',
      'Playful Bump': 'A light, flirty nudge.',
      'Warm Greeting': 'Kiss them when you first see them.',
      'Guided Relax': 'Rub their back while they debrief the day.',
      'Hug From Behind': 'A gentle surprise during a routine moment.',
      'Hand Through Hair': 'A relaxed, affectionate gesture.',
      'Goodbye Kiss': 'Keep the ritual alive, even for short departures.',
      'Touch + Words Combo': 'Hold their hand and share one appreciation.',
    };

    final byLove = <String>[
      if (primary.contains('service')) 'service',
      if (primary.contains('time')) 'time',
      if (primary.contains('gift')) 'gift',
      if (primary.contains('touch')) 'touch',
      if (primary.contains('word')) 'words',
    ];
    final diversity = ['service', 'time', 'words', 'gift', 'touch'];
    final ordered = <dynamic>{...byLove, ...diversity}.toList();

    String category;
    // For the first ever gesture we create, force primary love language
    if (state.isEmpty && byLove.isNotEmpty) {
      category = byLove.first;
    } else {
      final catIndex = weekStart.millisecondsSinceEpoch % ordered.length;
      category = ordered[catIndex];
    }

    String pickFrom(List<String> items) {
      final i = (weekStart.day + weekStart.month + weekStart.year) % items.length;
      return items[i];
    }

    String title;
    String? description;
    switch (category) {
      case 'service':
        title = pickFrom(service);
        description = desc[title];
        break;
      case 'time':
        title = pickFrom(time);
        description = desc[title];
        break;
      case 'gift':
        title = pickFrom(gift);
        description = desc[title];
        break;
      case 'touch':
        title = pickFrom(touch);
        description = desc[title];
        break;
      case 'words':
      default:
        title = pickFrom(words);
        description = desc[title];
        break;
    }

    return WeeklyGesture(
      id: _weekId(weekStart),
      title: title,
      category: category,
      weekStart: weekStart,
      description: description,
    );
  }

  // Return the bonus act if present, else null (does not mutate state)
  WeeklyGesture? findBonusForCurrentWeek() {
    final ws = _startOfWeek(DateTime.now());
    final baseId = _weekId(ws);
    final bonusId = '$baseId-bonus';
    return state.firstWhere(
      (g) => g.id == bonusId,
      orElse: () => WeeklyGesture(id: '', title: '', category: '', weekStart: ws),
    ).id == bonusId
        ? state.firstWhere((g) => g.id == bonusId)
        : null;
  }

  // Ensure a bonus act exists for current week; create & persist if missing.
  Future<void> ensureBonusForCurrentWeek() async {
    final ws = _startOfWeek(DateTime.now());
    final baseId = _weekId(ws);
    final bonusId = '$baseId-bonus';
    if (state.any((g) => g.id == bonusId)) return;

    final main = currentWeek();
    final partner = _ref.read(partnerProvider);
    final seed = DateTime.now().add(const Duration(minutes: 3));
    var suggestion = _generateGesture(partner, seed);
    suggestion = suggestion.copyWith(
      id: bonusId,
      weekStart: ws,
      category: main.category.isNotEmpty ? main.category : suggestion.category,
    );
    state = [...state, suggestion];
    await _save();
  }

  // ---------- Actions ----------
  Future<void> markComplete(String id) async {
    state = state
        .map((g) => g.id == id
            ? g.copyWith(completed: true, completedAt: DateTime.now())
            : g)
        .toList();
    await _save();
  }

  // ---------- Streak ----------
  int streak() {
    // Count consecutive completed weeks ending at the current week.
    final nowWs = _startOfWeek(DateTime.now());
    final completedWeeks = {
      for (final g in state)
        if (g.completed) _startOfWeek(g.weekStart)
    };
    int s = 0;
    var cursor = nowWs;
    while (completedWeeks.contains(cursor)) {
      s += 1;
      cursor = cursor.subtract(const Duration(days: 7));
    }
    return s;
  }

  // Longest streak across history
  int longestStreak() {
    // Collect unique completed week starts
    final weeks = <DateTime>{
      for (final g in state)
        if (g.completed)
          _startOfWeek(g.completedAt ?? g.weekStart),
    }.toList()
      ..sort();
    int best = 0;
    int current = 0;
    DateTime? prev;
    for (final w in weeks) {
      if (prev == null) {
        current = 1;
      } else {
        final diff = w.difference(prev).inDays;
        if (diff == 7) {
          current += 1;
        } else if (diff > 0) {
          current = 1; // non-consecutive, reset
        }
      }
      if (current > best) best = current;
      prev = w;
    }
    return best;
  }
}

// Top-level for compute: parse large JSON off the UI isolate
List<WeeklyGesture> _decodeWeeklyGestures(String raw) {
  final list = (jsonDecode(raw) as List)
      .map((e) => WeeklyGesture.fromJson(e as Map<String, dynamic>))
      .toList();
  return list;
}
