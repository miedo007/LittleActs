import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nudge/models/milestone.dart';
import 'package:nudge/shared/Services/notification_service.dart';
import 'package:nudge/shared/widgets/Providers/premium_provider.dart';

final milestonesProvider =
    StateNotifierProvider<MilestonesNotifier, List<Milestone>>(
  (ref) => MilestonesNotifier(ref),
);

class MilestonesNotifier extends StateNotifier<List<Milestone>> {
  MilestonesNotifier(this._ref) : super(const []) {
    _premiumSub = _ref.listen<bool>(premiumProvider, (previous, next) {
      if (next && previous != true) {
        _reschedule();
      }
    });
    _load();
  }

  final Ref _ref;
  late final ProviderSubscription<bool> _premiumSub;
  static const _key = 'milestones';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = await compute(_decodeMilestones, raw);
      state = list;
      await _reschedule(); // ensure notifications match saved data
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((m) => m.toJson()).toList());
    await prefs.setString(_key, json);
  }

  // ---------- CRUD ----------
  Future<void> add(Milestone m) async {
    state = [
      ...state.where((existing) => existing.id != m.id),
      m,
    ];
    await _save();
    await _reschedule();
  }

  Future<void> remove(String id) async {
    state = state.where((m) => m.id != id).toList();
    await _save();
    await _reschedule();
  }

  Future<void> clear() async {
    state = const [];
    await _save();
    await _reschedule();
  }

  // ---------- Notification Sync ----------
  Future<void> _reschedule() async {
    if (!_ref.read(premiumProvider)) return;
    // Build the list of next occurrences (handles yearly repeats)
    final now = DateTime.now();
    final nextDates = <DateTime>[];
    final names = <String>[];
    for (final m in state) {
      final next = (!m.repeatYearly)
          ? m.date
          : (() {
              final thisYear = DateTime(now.year, m.date.month, m.date.day);
              return thisYear.isAfter(now)
                  ? thisYear
                  : DateTime(now.year + 1, m.date.month, m.date.day);
            })();
      nextDates.add(next);
      names.add(m.name);
    }

    // Schedule reminders 7 days before each milestone
    if (nextDates.isEmpty) return;
    await NotificationService().scheduleMilestoneReminders(
      nextDates,
      names: names,
      daysBefore: 3,
    );
  }

  @override
  void dispose() {
    _premiumSub.close();
    super.dispose();
  }
}

// Top-level for compute: parse milestones off the UI isolate
List<Milestone> _decodeMilestones(String raw) {
  final list = (jsonDecode(raw) as List)
      .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
      .toList();
  return list;
}
