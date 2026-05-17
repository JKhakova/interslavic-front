import 'dart:io';

class ApiConfig {
  ApiConfig._();

  static final ApiConfig instance = ApiConfig._();

  static const String _apiHostOverride = String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );
  static const int _apiPort = int.fromEnvironment(
    'API_PORT',
    defaultValue: 5007,
  );

  String? _runtimeBaseUrlOverride;

  String get _resolvedHost {
    if (_apiHostOverride.isNotEmpty) {
      return _apiHostOverride;
    }

    // Android emulator reaches host machine loopback via 10.0.2.2.
    if (Platform.isAndroid) {
      return '10.0.2.2';
    }

    return '127.0.0.1';
  }

  String get apiBaseUrl => _runtimeBaseUrlOverride ?? 'http://$_resolvedHost:$_apiPort';

  String get currentHostPort {
    final uri = Uri.parse(apiBaseUrl);
    return '${uri.host}:${uri.port}';
  }

  bool setHostPort(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return false;
    }

    final normalizedValue = trimmedValue.startsWith('http://') ||
            trimmedValue.startsWith('https://')
        ? trimmedValue
        : 'http://$trimmedValue';

    final uri = Uri.tryParse(normalizedValue);
    if (uri == null || uri.host.isEmpty || uri.port <= 0) {
      return false;
    }

    _runtimeBaseUrlOverride = '${uri.scheme}://${uri.host}:${uri.port}';
    return true;
  }
}
