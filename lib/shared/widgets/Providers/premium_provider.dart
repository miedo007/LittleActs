import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>(
  (ref) => PremiumNotifier(),
);

class PremiumProducts {
  final ProductDetails? weekly;
  final ProductDetails? yearly;
  const PremiumProducts({this.weekly, this.yearly});
}

final premiumProductsProvider = FutureProvider<PremiumProducts>((ref) async {
  final iap = InAppPurchase.instance;
  final available = await iap.isAvailable();
  if (!available) return const PremiumProducts();
  final resp = await iap.queryProductDetails({
    PremiumNotifier.weeklyProductId,
    PremiumNotifier.yearlyProductId,
  });
  ProductDetails? weekly;
  ProductDetails? yearly;
  for (final p in resp.productDetails) {
    if (p.id == PremiumNotifier.weeklyProductId) weekly = p;
    if (p.id == PremiumNotifier.yearlyProductId) yearly = p;
  }
  return PremiumProducts(weekly: weekly, yearly: yearly);
});

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier() : super(false) {
    _init();
  }

  static const _key = 'is_premium';
  static const String weeklyProductId = 'com.nudge.premium.weekly';
  static const String yearlyProductId = 'com.nudge.premium.yearly';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _iapAvailable = false;

  Future<void> _init() async {
    // Load persisted entitlement
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;

    // Initialize IAP and listen for purchases
    _iapAvailable = await _iap.isAvailable();
    _sub = _iap.purchaseStream.listen(_onPurchaseUpdated, onDone: () {
      _sub?.cancel();
    }, onError: (e) {
      // ignore errors for now
    });

    // Warm up billing with a product query
    if (_iapAvailable) {
      await _queryProducts();
    }
  }

  Future<void> _queryProducts() async {
    final ids = {weeklyProductId, yearlyProductId};
    await _iap.queryProductDetails(ids);
  }

  Future<void> _set(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, v);
    state = v;
  }

  // Purchase APIs (called from UI)
  Future<void> buyWeekly() => _buy(weeklyProductId);
  Future<void> buyYearly() => _buy(yearlyProductId);

  Future<void> _buy(String productId) async {
    if (!_iapAvailable) {
      _iapAvailable = await _iap.isAvailable();
      if (!_iapAvailable) return;
    }
    final response = await _iap.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
      return;
    }
    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  Future<void> downgrade() => _set(false);

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final isEntitled =
              p.productID == weeklyProductId || p.productID == yearlyProductId;
          if (isEntitled) {
            await _set(true);
          }
          if (p.pendingCompletePurchase) {
            await _iap.completePurchase(p);
          }
          break;
        case PurchaseStatus.error:
          if (p.pendingCompletePurchase) {
            await _iap.completePurchase(p);
          }
          break;
        case PurchaseStatus.canceled:
          break;
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
