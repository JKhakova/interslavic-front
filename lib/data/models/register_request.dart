class RegisterRequest {
  const RegisterRequest({
    required this.fullname,
    required this.email,
    required this.login,
    required this.password,
  });

  final String fullname;
  final String email;
  final String login;
  final String password;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fullname': fullname,
      'email': email,
      'login': login,
      'password': password,
    };
  }
}
