import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../state/user_state.dart';
import 'analytics_service.dart';

class RevenueCatService extends ChangeNotifier {
  static const _appleApiKey = 'appl_RPNUxXhvXrpnWAiTvMswDDrigtJ';
  static const _entitlementId = 'Intended+';
  static const _boostEntitlementId = 'Intended Boost';
  static const _boostProductId = 'com.intendedapp.boost';

  final UserState _userState;

  bool _isPremium = false;
  bool _hasBoost = false;
  Offerings? _offerings;
  bool _isInitialized = false;

  RevenueCatService(this._userState);

  bool get isPremium => _isPremium;
  bool get hasBoost => _hasBoost;
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
    final boostEntitlement = customerInfo.entitlements.all[_boostEntitlementId];
    final wasPremium = _isPremium;
    final hadBoost = _hasBoost;
    _isPremium = entitlement?.isActive ?? false;
    _hasBoost = boostEntitlement?.isActive ?? false;

    if (wasPremium != _isPremium || hadBoost != _hasBoost) {
      _userState.setSubscription(_isPremium);
      _userState.setBoost(_hasBoost);
      final status = _isPremium ? 'premium' : _hasBoost ? 'boost' : 'free';
      AnalyticsService.setSubscriptionStatus(status);
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
      final result = await Purchases.purchasePackage(package);
      _updatePremiumStatus(result.customerInfo);
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

  /// Purchase the Intended Boost (one-time, non-consumable).
  /// Returns true if the boost entitlement is active after purchase.
  Future<bool> purchaseBoost() async {
    final package = getPackageByProductId(_boostProductId);
    if (package == null) {
      debugPrint('RevenueCat: Boost package not found for $_boostProductId');
      return false;
    }

    try {
      final result = await Purchases.purchasePackage(package);
      _updatePremiumStatus(result.customerInfo);
      return _hasBoost;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      debugPrint('RevenueCat: Boost purchase error: $e');
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

  /// Log in to RevenueCat with a user identifier (device ID or Firebase UID)
  Future<void> logIn(String userId) async {
    if (!_isInitialized) return;
    try {
      final result = await Purchases.logIn(userId);
      _updatePremiumStatus(result.customerInfo);
    } catch (e) {
      debugPrint('RevenueCat: logIn failed: $e');
    }
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
