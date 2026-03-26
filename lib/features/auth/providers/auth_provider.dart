import 'package:flutter/material.dart';

import '../models/auth_action_result.dart';
import '../services/auth_local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthLocalStorageService? authLocalStorageService,
  }) : _authLocalStorageService =
            authLocalStorageService ?? AuthLocalStorageService();

  final AuthLocalStorageService _authLocalStorageService;

  bool _isBusy = false;
  String? _errorMessage;
  String? _infoMessage;

  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;

  Future<AuthActionResult> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runAction(
      () => _authLocalStorageService.createLocalAccount(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<AuthActionResult> signIn({
    required String email,
    required String password,
  }) async {
    return _runAction(
      () => _authLocalStorageService.signInWithLocalAccount(
        email: email,
        password: password,
      ),
    );
  }

  Future<AuthActionResult> continueAsGuest() async {
    return _runAction(_authLocalStorageService.continueAsGuest);
  }

  Future<AuthActionResult> continueWithGoogle() async {
    return _runAction(_authLocalStorageService.signInWithGoogle);
  }

  Future<AuthActionResult> logOut() async {
    return _runAction(_authLocalStorageService.logOut);
  }

  Future<String?> getSavedLocalAccountEmail() {
    return _authLocalStorageService.getSavedLocalAccountEmail();
  }

  void clearMessages() {
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  Future<AuthActionResult> _runAction(
    Future<AuthActionResult> Function() action,
  ) async {
    _isBusy = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    final result = await action();

    _isBusy = false;
    if (result.isSuccess) {
      _infoMessage = result.message;
    } else {
      _errorMessage = result.message;
    }

    notifyListeners();
    return result;
  }
}
