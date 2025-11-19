import 'package:flutter/material.dart';
import '../models/cupon.dart';
import '../services/cupon_service.dart';

class CouponViewModel extends ChangeNotifier {
  final CouponService _couponService = CouponService();

  List<Coupon> availableCoupons = [];
  List<Coupon> userCoupons = [];

  Stream<List<Coupon>>? _availableStream;
  Stream<List<Coupon>>? _userStream;

  bool isLoading = false;

  bool _hasLoadedInitialCoupons = false;
  bool get hasLoadedInitialCoupons => _hasLoadedInitialCoupons;

  Future<void> loadAvailableCoupons() async {
    availableCoupons = await _couponService.getAvailableCoupons();
    _hasLoadedInitialCoupons = true;
    notifyListeners();

    _availableStream = _couponService.listenAvailableCoupons();
    _availableStream!.listen((coupons) {
      availableCoupons = coupons;
      notifyListeners();
    });
  }

  Future<void> loadUserCoupons(String userId) async {
    userCoupons = await _couponService.getUserCoupons(userId);
    notifyListeners();

    _userStream = _couponService.listenUserCoupons(userId);
    _userStream!.listen((coupons) {
      userCoupons = coupons;
      notifyListeners();
    });
  }

  Future<bool> redeemCoupon({
    required String couponId,
    required String userId,
    required int cost,
  }) async {
    final success = await _couponService.redeemCouponAndDeductPoints(
      couponId: couponId,
      userId: userId,
      cost: cost,
    );

    if (success) {
      await loadAvailableCoupons();
      await loadUserCoupons(userId);
    }

    return success;
  }

  Future<bool> adminMarkCouponAsSpent({
    required String couponId,
    required String adminId,
  }) async {
    isLoading = true;
    notifyListeners();

    final success = await _couponService.adminMarkCouponAsSpent(
      couponId: couponId,
      adminId: adminId,
    );

    isLoading = false;
    notifyListeners();

    return success;
  }
}
