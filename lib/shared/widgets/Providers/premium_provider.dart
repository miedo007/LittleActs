import 'dart:async';

import 'package:flutter/foundation.dart';
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
  final resp =
      await iap.queryProductDetails(PremiumNotifier.allProductIds);
  final products = resp.productDetails;
  final weekly = _selectFirstMatchingProduct(
    products,
    PremiumNotifier.weeklyProductCandidates,
  );
  final yearly = _selectFirstMatchingProduct(
    products,
    PremiumNotifier.yearlyProductCandidates,
  );
  return PremiumProducts(weekly: weekly, yearly: yearly);
});

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier() : super(false) {
    _init();
  }

  static const _key = 'is_premium';
  static const String entitlementPrefsKey = _key;
  static const List<String> weeklyProductCandidates = [
    'Weekly5.99',
    'com.thescript.littleacts.Weekly5.99',
    'com.thescript.litteacts.Weekly5.99',
    'com.thescript.litteacts.premium.weekly',
    'com.thescript.littleacts.premium.weekly',
    'com.nudge.premium.weekly',
  ];
  static const List<String> yearlyProductCandidates = [
    'Yearly49.99',
    'com.thescript.littleacts.Yearly49.99',
    'com.thescript.litteacts.Yearly49.99',
    'com.thescript.litteacts.premium.yearly',
    'com.thescript.littleacts.premium.yearly',
    'com.nudge.premium.yearly',
  ];
  static Set<String> get allProductIds => {
        ...weeklyProductCandidates,
        ...yearlyProductCandidates,
      };

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _iapAvailable = false;
  ProductDetails? _weeklyProduct;
  ProductDetails? _yearlyProduct;

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
    await _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    if (!await _ensureAvailable()) return;
    final resp = await _iap.queryProductDetails(allProductIds);
    _cacheProducts(resp.productDetails);
  }

  void _cacheProducts(Iterable<ProductDetails> products) {
    final list = products.toList();
    final weekly = _selectFirstMatchingProduct(
      list,
      weeklyProductCandidates,
    );
    final yearly = _selectFirstMatchingProduct(
      list,
      yearlyProductCandidates,
    );
    if (weekly != null) _weeklyProduct = weekly;
    if (yearly != null) _yearlyProduct = yearly;
  }

  Future<void> _set(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, v);
    state = v;
  }

  // Purchase APIs (called from UI)
  Future<void> buyWeekly() => _buy(weekly: true);
  Future<void> buyYearly() => _buy(weekly: false);

  Future<void> _buy({required bool weekly}) async {
    if (!await _ensureAvailable()) {
      debugPrint('In-app purchases are not available on this device.');
      return;
    }
    await _ensureProductsResolved();
    final product = weekly ? _weeklyProduct : _yearlyProduct;
    if (product == null) {
      throw StateError(
        weekly
            ? 'Weekly subscription product is not configured for this bundle.'
            : 'Yearly subscription product is not configured for this bundle.',
      );
    }
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
              weeklyProductCandidates.contains(p.productID) ||
              yearlyProductCandidates.contains(p.productID);
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

  Future<bool> _ensureAvailable() async {
    if (!_iapAvailable) {
      _iapAvailable = await _iap.isAvailable();
    }
    return _iapAvailable;
  }

  Future<void> _ensureProductsResolved() async {
    if (_weeklyProduct != null && _yearlyProduct != null) return;
    await _refreshProducts();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

ProductDetails? _selectFirstMatchingProduct(
  Iterable<ProductDetails> products,
  List<String> preferredIds,
) {
  if (products.isEmpty) return null;
  final byId = <String, ProductDetails>{
    for (final product in products) product.id: product,
  };
  for (final id in preferredIds) {
    final product = byId[id];
    if (product != null) return product;
  }
  return null;
}
