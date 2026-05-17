import 'package:flutter_application_1/data/models/token_pair.dart';
import 'package:flutter_application_1/data/models/user_model.dart';

class AuthResponse {
  const AuthResponse({required this.tokens, required this.user});

  final TokenPair tokens;
  final UserModel user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final tokenJson =
        (json['tokens'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final userJson =
        (json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return AuthResponse(
      tokens: TokenPair.fromJson(tokenJson),
      user: UserModel.fromJson(userJson),
    );
  }
}
