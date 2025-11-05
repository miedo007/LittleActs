import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nudge/models/partner.dart';
import 'package:nudge/models/milestone.dart';
import 'package:nudge/shared/widgets/Providers/milestones_provider.dart';

final partnerProvider = StateNotifierProvider<PartnerNotifier, Partner?>((ref) => PartnerNotifier(ref));

class PartnerNotifier extends StateNotifier<Partner?> {
  final Ref ref;
  PartnerNotifier(this.ref) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('partner');
    if (raw != null) {
      state = await compute(_decodePartner, raw);
    }
  }

  Future<void> savePartner(Partner partner) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('partner', jsonEncode(partner.toJson()));
    state = partner;

    // Ensure birthday milestone exists once a birthday is known
    if (partner.birthday != null) {
      final ms = ref.read(milestonesProvider);
      final exists = ms.any((m) => m.id == 'birthday');
      if (!exists) {
        await ref.read(milestonesProvider.notifier).add(
              Milestone(
                id: 'birthday',
                name: "Partner's Birthday",
                date: partner.birthday!,
                repeatYearly: true,
              ),
            );
      }
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('partner');
    state = null;
  }
}

// Top-level for compute: parse partner JSON off the UI isolate
Partner _decodePartner(String raw) {
  return Partner.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
