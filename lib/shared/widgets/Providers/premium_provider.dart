import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>(
  (ref) => PremiumNotifier(),
);

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier() : super(false) {
    _load();
  }

  static const _key = 'is_premium';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> _set(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, v);
    state = v;
  }

  // Mock purchase / restore for now
  Future<void> upgrade() => _set(true);
  Future<void> restore() => _set(prefsBackfill());

  // If you want restore to just read saved value:
  bool prefsBackfill() => state; // placeholder — will be replaced by real restore later
}
