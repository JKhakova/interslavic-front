class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.fullname,
    required this.login,
    required this.role,
    required this.lastLogin,
    required this.regDate,
  });

  final int id;
  final String email;
  final String fullname;
  final String login;
  final String role;
  final String lastLogin;
  final String regDate;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as int?) ?? 0,
      email: (json['email'] as String?) ?? '',
      fullname: (json['fullname'] as String?) ?? '',
      login: (json['login'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      lastLogin: (json['last_login'] as String?) ?? '',
      regDate: (json['reg_date'] as String?) ?? '',
    );
  }
}
