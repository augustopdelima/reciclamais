import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        .where('spentByAdmin', isEqualTo: false)
        .get();

    return query.docs
        .map((doc) => Coupon.fromFirestore(doc.data(), doc.id))
        .toList();
  }

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

  Future<bool> redeemCouponAndDeductPoints({
    required String couponId,
    required String userId,
    required int cost,
  }) async {
    final userRef = _db.collection('users').doc(userId);
    final couponRef = _db.collection('cupons').doc(couponId);

    final historyCollectionRef = _db.collection('redeem_history');

    try {
      await _db.runTransaction((tx) async {
        final userDoc = await tx.get(userRef);
        final couponDoc = await tx.get(couponRef);

        if (!userDoc.exists || !couponDoc.exists) {
          throw Exception('Usuário ou cupom não encontrado.');
        }

        final userPoints = userDoc.data()?['points'] ?? 0;
        final couponData = couponDoc.data()!;
        final assignedTo = couponData['assignedTo'];
        final redeemed = couponData['redeemed'] ?? false;

        final couponDescription =
            couponData['descricao'] ?? 'Cupom de Desconto';
        final couponDiscount = couponData['valorDesconto'] ?? 0;

        if (userPoints < cost) {
          throw Exception('Pontos insuficientes.');
        }

        if (assignedTo != null || redeemed) {
          throw Exception('Cupom já resgatado ou reservado.');
        }

        tx.update(userRef, {'points': userPoints - cost});

        tx.update(couponRef, {
          'assignedTo': userId,
          'redeemed': true,
          'usuarioId': userId,
          'redeemedAt': FieldValue.serverTimestamp(),
        });

        tx.set(historyCollectionRef.doc(), {
          'userId': userId,
          'couponId': couponId,
          'description': couponDescription,
          'discountValue': couponDiscount,
          'costPoints': cost,
          'redeemedAt': FieldValue.serverTimestamp(),
          // Referência opcional ao documento original do cupom
          'couponDocRef': couponRef,
        });
      });

      return true;
    } catch (e) {
      print('Erro ao resgatar cupom: $e');
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> streamAllRedeemedCoupons() {
    return _db
        .collection('cupons')
        .where('assignedTo', isNotEqualTo: null)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> streamUserRedeemedCoupons(String userId) {
    return _db
        .collection('cupons')
        .where('assignedTo', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  Future<List<Map<String, dynamic>>> searchRedeemedCoupons(String text) async {
    final query = await _db.collection('cupons').get();

    final lower = text.toLowerCase();

    final redeemed = query.docs.where((doc) {
      final data = doc.data();
      return data['assignedTo'] != null;
    });

    return redeemed
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        })
        .where((data) {
          final title = (data['descricao'] ?? "").toLowerCase();
          final desc = (data['valorDesconto']?.toString() ?? "").toLowerCase();
          final user = (data['assignedTo'] ?? "").toLowerCase();

          return title.contains(lower) ||
              desc.contains(lower) ||
              user.contains(lower);
        })
        .toList();
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

  Future<void> reserveAndRedeem(String couponDocId, String userId) async {
    try {
      // Reserva o cupom
      await redeemCoupon(couponDocId, userId);

      // Marca como resgatado
      await markAsRedeemed(couponDocId);
    } catch (e) {
      throw Exception('Erro ao resgatar o cupom: $e');
    }
  }

  Future<bool> tryReserveCoupon(String couponDocId, String userId) async {
    final doc = await _db.collection('cupons').doc(couponDocId).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    if (data['assignedTo'] != null || data['redeemed'] == true) {
      // cupom já foi reservado ou resgatado
      return false;
    }

    await redeemCoupon(couponDocId, userId);
    return true;
  }

  Future<bool> adminMarkCouponAsSpent({
    required String couponId,
    required String adminId,
  }) async {
    final couponRef = _db.collection('cupons').doc(couponId);

    final user = FirebaseAuth.instance.currentUser!;
    final idTokenResult = await user.getIdTokenResult(
      true,
    ); // força atualização
    print("Claims do usuário: ${idTokenResult.claims}");

    try {
      await _db.runTransaction((tx) async {
        final snapshot = await tx.get(couponRef);
        if (!snapshot.exists) throw Exception('Cupom não encontrado');

        final data = snapshot.data()!;

        // Verifica se já foi marcado como spent pelo admin
        final alreadySpent = data['redeemedByAdmin'] != null;
        if (alreadySpent) {
          throw Exception('Cupom já foi marcado como gasto pelo admin');
        }

        final assignedTo = data['assignedTo'];
        final description = data['descricao'] ?? '';
        final discountValue = data['valorDesconto'] ?? 0;
        final costPoints = data['costPoints'] ?? 0;

        // → Marca como spent pelo admin (não mexe em redeemed)
        tx.update(couponRef, {
          'redeemedByAdmin': adminId,
          'spentAt': FieldValue.serverTimestamp(),
          'spentByAdmin': true,
        });

        // → Cria histórico compatível com seu model RedeemHistoryItem
        tx.set(_db.collection('redeem_history').doc(), {
          'couponId': couponId,
          'userId': assignedTo,
          'description': description,
          'discountValue': discountValue,
          'costPoints': costPoints,
          'couponDocRef': couponRef,
          'redeemedAt': FieldValue.serverTimestamp(),
          'adminId': adminId,
          'action': 'admin_mark_spent',
        });
      });

      return true;
    } catch (e) {
      print('Erro em adminMarkCouponAsSpent: $e');
      return false;
    }
  }
}
