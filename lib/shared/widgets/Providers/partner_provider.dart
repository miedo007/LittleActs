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
    // Merge with existing so partial updates (e.g., from different flows)
    // don’t wipe previously entered fields like togetherSince/birthday.
    final existing = state;
    final merged = Partner(
      name: partner.name.isNotEmpty ? partner.name : (existing?.name ?? ''),
      birthday: partner.birthday ?? existing?.birthday,
      togetherSince: partner.togetherSince ?? existing?.togetherSince,
      gender: partner.gender ?? existing?.gender,
      loveLanguagePrimary: partner.loveLanguagePrimary ?? existing?.loveLanguagePrimary,
      loveLanguageSecondary: partner.loveLanguageSecondary ?? existing?.loveLanguageSecondary,
      favorites: partner.favorites ?? existing?.favorites,
      dislikes: partner.dislikes ?? existing?.dislikes,
      budget: partner.budget ?? existing?.budget,
      qualityTime: partner.qualityTime ?? existing?.qualityTime,
      wordsOfAffirmation: partner.wordsOfAffirmation ?? existing?.wordsOfAffirmation,
      actsOfService: partner.actsOfService ?? existing?.actsOfService,
      physicalTouch: partner.physicalTouch ?? existing?.physicalTouch,
      receivingGifts: partner.receivingGifts ?? existing?.receivingGifts,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('partner', jsonEncode(merged.toJson()));
    state = merged;

    // Ensure birthday milestone exists once a birthday is known
    if (merged.birthday != null) {
      final ms = ref.read(milestonesProvider);
      final exists = ms.any((m) => m.id == 'birthday');
      if (!exists) {
        await ref.read(milestonesProvider.notifier).add(
              Milestone(
                id: 'birthday',
                name: "Partner's Birthday",
                date: merged.birthday!,
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
