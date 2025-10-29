import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cupon.dart';

class CouponService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Coupon>> getAvailableCoupons() async {
    final query = await _db
        .collection('cupons')
        .where('assignedTo', isNull: true)
        .where('redeemed', isEqualTo: false)
        .get();

    return query.docs
        .map((doc) => Coupon.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Coupon>> listenAvailableCoupons() {
    return _db
        .collection('cupons')
        .where('assignedTo', isNull: true)
        .where('redeemed', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Coupon.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<List<Coupon>> getUserCoupons(String userId) async {
    final query = await _db
        .collection('cupons')
        .where('assignedTo', isEqualTo: userId)
        .get();

    return query.docs
        .map((doc) => Coupon.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// 🔹 Stream para ouvir cupons de um usuário
  Stream<List<Coupon>> listenUserCoupons(String userId) {
    return _db
        .collection('cupons')
        .where('assignedTo', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Coupon.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> redeemCoupon(String couponDocId, String userId) async {
    await _db.collection('cupons').doc(couponDocId).update({
      'assignedTo': userId,
      'redeemed': false, // apenas reservado, ainda não usado
      'usuarioId': userId, // compatibilidade
    });
  }

  Future<void> markAsRedeemed(String couponDocId) async {
    await _db.collection('cupons').doc(couponDocId).update({'redeemed': true});
  }
}
