import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cupon_service.dart';
import '../models/cupon.dart';
import '../models/user.dart';

class AdminCouponsViewModel extends ChangeNotifier {
  final CouponService _couponService = CouponService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Coupon> _coupons = [];
  List<Coupon> get coupons => _coupons;

  Map<String, UserModel> _usersCache = {}; // cache em memória
  bool isLoading = false;
  String searchText = '';

  AdminCouponsViewModel() {
    _loadCache();
  }

  /// Carrega o cache permanente do SharedPreferences
  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('usersCache');
    if (jsonString != null) {
      final Map<String, dynamic> map = json.decode(jsonString);
      _usersCache = map.map(
        (key, value) => MapEntry(key, UserModel.fromJson(value)),
      );
    }
  }

  /// Salva o cache permanente no SharedPreferences
  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _usersCache.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString('usersCache', json.encode(map));
  }

  void updateSearch(String value) {
    searchText = value.trim();
    if (searchText.isEmpty) {
      _coupons = [];
      notifyListeners();
      return;
    }
    searchCoupons(searchText);
  }

  Future<void> searchCoupons(String query) async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('cupons')
          .where('assignedTo', isNotEqualTo: null)
          .where('redeemed', isEqualTo: true)
          .where('spentByAdmin', isEqualTo: false)
          .get();

      List<Coupon> tempCoupons = [];

      for (var doc in snapshot.docs) {
        final coupon = Coupon.fromFirestore(doc.data(), doc.id);

        UserModel? user;
        if (coupon.assignedTo != null) {
          user = _usersCache[coupon.assignedTo];
          if (user == null) {
            final userDoc = await _db
                .collection('users')
                .doc(coupon.assignedTo)
                .get();
            if (userDoc.exists) {
              user = UserModel.fromFirestore(userDoc);
              _usersCache[coupon.assignedTo!] = user; // salva em memória
              await _saveCache(); // salva no SharedPreferences
            }
          }
        }

        if (user == null) continue;

        final q = query.toLowerCase();
        final matchesCoupon =
            coupon.descricao.toLowerCase().contains(q) ||
            coupon.id.toLowerCase().contains(q);
        final matchesUser =
            user.name.toLowerCase().contains(q) ||
            user.email.toLowerCase().contains(q);

        if (matchesCoupon || matchesUser) {
          tempCoupons.add(coupon);
        }
      }

      _coupons = tempCoupons;
    } catch (e) {
      print('Erro ao buscar cupons: $e');
      _coupons = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> markAsSpent(String couponId, String adminId) async {
    return await _couponService.adminMarkCouponAsSpent(
      couponId: couponId,
      adminId: adminId,
    );
  }

  UserModel? getUserForCoupon(String assignedTo) {
    return _usersCache[assignedTo];
  }
}
