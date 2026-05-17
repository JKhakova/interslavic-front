import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/auth_response.dart';
import 'package:flutter_application_1/data/models/login_request.dart';
import 'package:flutter_application_1/data/models/register_request.dart';
import 'package:flutter_application_1/data/services/api_config.dart';
import 'package:flutter_application_1/data/services/auth_api_service.dart';
import 'dart:io';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthApiService authApiService})
    : _authApiService = authApiService;

  final AuthApiService _authApiService;

  AuthResponse? _authResponse;
  bool _isLoading = false;
  String? _errorText;

  bool get isLoading => _isLoading;
  String? get errorText => _errorText;
  bool get isAuthorized => _authResponse != null;
  AuthResponse? get authResponse => _authResponse;

  Future<bool> login({
    required String login,
    required String password,
    required String backendHostPort,
  }) async {
    final trimmedLogin = login.trim();
    final trimmedBackendHostPort = backendHostPort.trim();

    if (trimmedLogin.isEmpty ||
        password.isEmpty ||
        trimmedBackendHostPort.isEmpty) {
      _errorText = 'Введите ip:port, логин и пароль';
      notifyListeners();
      return false;
    }

    if (!ApiConfig.instance.setHostPort(trimmedBackendHostPort)) {
      _errorText = 'Некорректный адрес бэкенда. Используйте формат ip:port';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorText = null;

    try {
      final response = await _authApiService.login(
        LoginRequest(login: trimmedLogin, password: password),
      );

      _authResponse = response;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorText = e.message;
      notifyListeners();
      return false;
    } on SocketException {
      _errorText =
          'Нет соединения с сервером ${_authApiService.apiBaseUrl}. Проверьте, что бэкенд доступен из сети и слушает 0.0.0.0.';
      notifyListeners();
      return false;
    } catch (_) {
      _errorText =
          'Не удалось выполнить вход. Попробуйте позже (${_authApiService.apiBaseUrl})';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String backendHostPort,
    required String fullname,
    required String email,
    required String login,
    required String password,
  }) async {
    final trimmedBackendHostPort = backendHostPort.trim();
    final trimmedFullname = fullname.trim();
    final trimmedEmail = email.trim();
    final trimmedLogin = login.trim();

    if (trimmedBackendHostPort.isEmpty ||
        trimmedFullname.isEmpty ||
        trimmedEmail.isEmpty ||
        trimmedLogin.isEmpty ||
        password.isEmpty) {
      _errorText = 'Заполните ip:port, полное имя, email, логин и пароль';
      notifyListeners();
      return false;
    }

    if (!ApiConfig.instance.setHostPort(trimmedBackendHostPort)) {
      _errorText = 'Некорректный адрес бэкенда. Используйте формат ip:port';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorText = null;

    try {
      await _authApiService.register(
        RegisterRequest(
          fullname: trimmedFullname,
          email: trimmedEmail,
          login: trimmedLogin,
          password: password,
        ),
      );
      _errorText = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorText = e.message;
      notifyListeners();
      return false;
    } on SocketException {
      _errorText =
          'Нет соединения с сервером ${_authApiService.apiBaseUrl}. Проверьте, что бэкенд доступен из сети и слушает 0.0.0.0.';
      notifyListeners();
      return false;
    } catch (_) {
      _errorText =
          'Не удалось выполнить регистрацию. Попробуйте позже (${_authApiService.apiBaseUrl})';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _authResponse = null;
    _errorText = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
