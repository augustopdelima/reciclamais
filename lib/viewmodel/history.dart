import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/history.dart';
import '../models/user.dart';

class UserProfileViewModel with ChangeNotifier {
  final UserService _userService;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UserModel? _user;
  UserModel? get user => _user;

  List<RedeemHistoryItem> _redeemHistory = [];
  List<RedeemHistoryItem> get redeemHistory => _redeemHistory;

  List<CollectionHistoryItem> _collectionHistory = [];
  List<CollectionHistoryItem> get collectionHistory => _collectionHistory;

  HistoryType _selectedHistoryType = HistoryType.redeemedCoupons;
  HistoryType get selectedHistoryType => _selectedHistoryType;

  UserProfileViewModel(String userId) : _userService = UserService(userId) {
    loadUserData();
  }

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _userService.fetchUserProfile();

      final results = await Future.wait([
        _userService.fetchRedeemHistory(),
        _userService.fetchCollectionHistory(),
      ]);

      _redeemHistory = results[0] as List<RedeemHistoryItem>;
      _collectionHistory = results[1] as List<CollectionHistoryItem>;
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedHistoryType(HistoryType newType) {
    if (_selectedHistoryType != newType) {
      _selectedHistoryType = newType;
      notifyListeners();
    }
  }

  List<HistoryItem> get currentHistoryList {
    if (_selectedHistoryType == HistoryType.redeemedCoupons) {
      return _redeemHistory;
    } else {
      return _collectionHistory;
    }
  }
}
