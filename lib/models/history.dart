import 'package:cloud_firestore/cloud_firestore.dart';

enum HistoryType { redeemedCoupons, collectedPoints }

abstract class HistoryItem {
  DateTime get date;
  String get detail;
  int get points;
}

class RedeemHistoryItem implements HistoryItem {
  final String id;
  final String couponId;
  final String description;
  final int discountValue;
  final int costPoints;
  final DocumentReference couponDocRef;
  final DateTime redeemedAt;
  final String userId;

  RedeemHistoryItem({
    required this.id,
    required this.couponId,
    required this.description,
    required this.discountValue,
    required this.costPoints,
    required this.couponDocRef,
    required this.redeemedAt,
    required this.userId,
  });

  @override
  DateTime get date => redeemedAt;

  @override
  String get detail => description;

  @override
  int get points => costPoints;

  factory RedeemHistoryItem.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return RedeemHistoryItem(
      id: docId,
      couponId: data['couponId'] ?? '',
      description: data['description'] ?? '',
      discountValue: data['discountValue'] ?? 0,
      costPoints: data['costPoints'] ?? 0,
      couponDocRef: data['couponDocRef'] as DocumentReference,
      redeemedAt: (data['redeemedAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }
}

class CollectionHistoryItem implements HistoryItem {
  final String id;
  final String itemId;
  final String description;
  final int pointsEarned;
  final DateTime collectedAt;
  final String userId;

  CollectionHistoryItem({
    required this.id,
    required this.itemId,
    required this.description,
    required this.pointsEarned,
    required this.collectedAt,
    required this.userId,
  });

  @override
  DateTime get date => collectedAt;

  @override
  String get detail => description;

  @override
  int get points => pointsEarned;

  factory CollectionHistoryItem.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return CollectionHistoryItem(
      id: docId,
      itemId: data['itemId'] ?? '',
      description: data['description'] ?? '',
      pointsEarned: data['pointsEarned'] ?? 0,
      collectedAt: (data['collectedAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }
}
