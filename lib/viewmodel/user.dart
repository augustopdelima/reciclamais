import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';

class UserViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  StreamSubscription<Map<String, dynamic>?>? _userSubscription;

  Map<String, dynamic>? get userData => _userData;
  String get userName => _userData?['name'] ?? 'Usuário';
  int get userPoints => _userData?['points'] ?? 0;
  String get userRole => _userData?['role'];

  String? get currentUserId => _authService.currentUser?.uid;

  void startUserListener() {
    final user = _authService.currentUser;

    if (user == null) {
      stopUserListener();
      return;
    }

    if (_userSubscription != null) {
      return;
    }

    _userSubscription?.cancel();

    _userSubscription = _authService
        .listenUserData(user.uid)
        .listen(
          (data) {
            _userData = data;
            notifyListeners();
          },
          onError: (e) {
            print('Erro ao ouvir dados do usuário no ViewModel: $e');
            _userData = null;
            notifyListeners();
          },
        );
  }

  Future<void> logout() async {
    await _authService.logout();
    stopUserListener();
  }

  void stopUserListener() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _userData = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopUserListener();
    super.dispose();
  }
}
