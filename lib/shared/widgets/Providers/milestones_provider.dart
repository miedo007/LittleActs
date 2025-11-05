import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nudge/models/milestone.dart';
import 'package:nudge/shared/Services/notification_service.dart';

final milestonesProvider =
    StateNotifierProvider<MilestonesNotifier, List<Milestone>>(
  (ref) => MilestonesNotifier(),
);

class MilestonesNotifier extends StateNotifier<List<Milestone>> {
  MilestonesNotifier() : super(const []) {
    _load();
  }

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
    state = [...state, m];
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
    // Build the list of next occurrences (handles yearly repeats)
    final now = DateTime.now();
    final nextDates = state.map((m) {
      if (!m.repeatYearly) return m.date;
      final thisYear = DateTime(now.year, m.date.month, m.date.day);
      return thisYear.isAfter(now)
          ? thisYear
          : DateTime(now.year + 1, m.date.month, m.date.day);
    }).toList();

    // Schedule reminders 7 days before each milestone
    await NotificationService().scheduleMilestoneReminders(
      nextDates,
      daysBefore: 7,
    );
  }
}

// Top-level for compute: parse milestones off the UI isolate
List<Milestone> _decodeMilestones(String raw) {
  final list = (jsonDecode(raw) as List)
      .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
      .toList();
  return list;
}
