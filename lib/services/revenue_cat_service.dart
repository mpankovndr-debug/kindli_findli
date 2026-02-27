import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService extends ChangeNotifier {
  static const _appleApiKey = 'appl_RPNUxXhvXrpnWAiTvMswDDrigtJ';
  static const _entitlementId = 'Intended+';

  bool _isPremium = false;
  Offerings? _offerings;
  bool _isInitialized = false;

  bool get isPremium => _isPremium;
  Offerings? get offerings => _offerings;

  /// Initialize RevenueCat SDK (iOS only for now)
  Future<void> init() async {
    if (_isInitialized) return;

    if (!Platform.isIOS && !Platform.isMacOS) {
      // Android support will be added later
      _isInitialized = true;
      return;
    }

    final configuration = PurchasesConfiguration(_appleApiKey);
    await Purchases.configure(configuration);

    // Listen for customer info changes (e.g. subscription renewals, expirations)
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

    // Check current entitlement status
    await refreshPurchaseStatus();

    // Pre-fetch offerings
    await loadOfferings();

    _isInitialized = true;
  }

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    _updatePremiumStatus(customerInfo);
  }

  void _updatePremiumStatus(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[_entitlementId];
    final wasPremium = _isPremium;
    _isPremium = entitlement?.isActive ?? false;

    if (wasPremium != _isPremium) {
      notifyListeners();
    }
  }

  /// Refresh purchase status from RevenueCat
  Future<void> refreshPurchaseStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);
    } catch (e) {
      debugPrint('RevenueCat: Failed to get customer info: $e');
    }
  }

  /// Load available offerings
  Future<void> loadOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCat: Failed to load offerings: $e');
    }
  }

  /// Get the default offering's available packages
  List<Package> getPackages() {
    return _offerings?.current?.availablePackages ?? [];
  }

  /// Find a specific package by product identifier
  Package? getPackageByProductId(String productId) {
    final packages = getPackages();
    try {
      return packages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Purchase a specific package
  /// Returns true if purchase succeeded, false otherwise.
  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _updatePremiumStatus(customerInfo);
      return _isPremium;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled — not an error
        return false;
      }
      debugPrint('RevenueCat: Purchase error: $e');
      rethrow;
    }
  }

  /// Purchase by plan name (monthly, yearly, lifetime)
  /// Maps plan names to RevenueCat product IDs.
  Future<bool> purchasePlan(String plan) async {
    final productId = switch (plan) {
      'monthly' => 'com.intendedapp.plus.monthly',
      'yearly' => 'com.intendedapp.plus.yearly',
      'lifetime' => 'com.intendedapp.plus.lifetime',
      _ => throw ArgumentError('Unknown plan: $plan'),
    };

    final package = getPackageByProductId(productId);
    if (package == null) {
      debugPrint('RevenueCat: Package not found for $productId');
      return false;
    }

    return purchasePackage(package);
  }

  /// Restore purchases
  /// Returns true if user has active premium after restore.
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updatePremiumStatus(customerInfo);
      return _isPremium;
    } catch (e) {
      debugPrint('RevenueCat: Restore failed: $e');
      rethrow;
    }
  }
}
