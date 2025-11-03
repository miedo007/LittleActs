import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nudge/models/weekly_gesture.dart';
import 'package:nudge/models/partner.dart';
import 'package:nudge/shared/widgets/Providers/partner_provider.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';
import 'package:nudge/shared/Services/notification_service.dart';

// Public provider: exposes the current week gesture + history + streak.
final weeklyGesturesProvider =
    StateNotifierProvider<WeeklyGesturesNotifier, List<WeeklyGesture>>(
  (ref) => WeeklyGesturesNotifier(ref),
);

class WeeklyGesturesNotifier extends StateNotifier<List<WeeklyGesture>> {
  WeeklyGesturesNotifier(this._ref) : super(const []) {
    _load().then((_) async {
      await _ensureThisWeekGesture();
      await NotificationService().scheduleWeeklyNudge();
    });
  }

  final Ref _ref;
  static const _key = 'weekly_gestures';

  // ---------- Persistence ----------
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => WeeklyGesture.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
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
    return state.firstWhere(
      (g) => g.id == id,
      orElse: () => WeeklyGesture(
        id: id,
        title: '',
        category: '',
        weekStart: ws,
      ),
    );
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

    const service = [
      'Warm up their car before they leave',
      'Fold one load of their laundry',
      'Prep their morning coffee/tea',
      'Tidy their desk or side table',
      'Refill their water bottle',
    ];
    const time = [
      'Plan a 20-min phone-free walk',
      'Invite them for a 15-min stretch together',
      'Sit for 10-min and ask "How\'s your day?"',
      'Watch one short video they love together',
      'Eat a snack together without phones',
    ];
    const words = [
      'Leave a sticky note: one thing you admire about them',
      'Send a mid-day "thinking of you" text',
      'Write one sentence of genuine appreciation',
      'Compliment something they did this week',
      'Record a 10-sec voice note: "I love you because..."',
    ];
    final gift = <String>[
      if (isPro && fav != null && fav.isNotEmpty) 'Order their favorite: $fav',
      'Pick up their favorite snack',
      'Bring them a surprise coffee/tea',
      'Get a small flower/bouquet',
      'Buy a \$5 treat from their favorite store',
    ];
    const touch = [
      'Offer a 2-minute shoulder massage',
      'Hold hands during a walk',
      'Hug for a full 20 seconds',
      'Sit close and cuddle for 5 minutes',
      'Brush their hair / gentle head massage',
    ];

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
    switch (category) {
      case 'service':
        title = pickFrom(service);
        break;
      case 'time':
        title = pickFrom(time);
        break;
      case 'gift':
        title = pickFrom(gift);
        break;
      case 'touch':
        title = pickFrom(touch);
        break;
      case 'words':
      default:
        title = pickFrom(words);
        break;
    }

    return WeeklyGesture(
      id: _weekId(weekStart),
      title: title,
      category: category,
      weekStart: weekStart,
    );
  }

  // Return the bonus act if present, else null (does not mutate state)
  WeeklyGesture? findBonusForCurrentWeek() {
    final ws = _startOfWeek(DateTime.now());
    final baseId = _weekId(ws);
    final bonusId = '${baseId}-bonus';
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
    final bonusId = '${baseId}-bonus';
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
    if (state.isEmpty) return 0;
    final sorted = [...state]..sort((a, b) => a.weekStart.compareTo(b.weekStart));
    int s = 0;
    for (int i = sorted.length - 1; i >= 0; i--) {
      final g = sorted[i];
      if (g.completed) {
        s++;
      } else {
        break;
      }
    }
    return s;
  }
}
