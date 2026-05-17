import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api_config.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _backendController = TextEditingController(
    text: ApiConfig.instance.currentHostPort,
  );
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _backendFocusNode = FocusNode();
  final FocusNode _loginFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _backendController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _backendFocusNode.dispose();
    _loginFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    await context.read<AuthProvider>().login(
      backendHostPort: _backendController.text,
      login: _loginController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>(
      (provider) => provider.isLoading,
    );
    final errorText = context.select<AuthProvider, String?>(
      (provider) => provider.errorText,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const Spacer(flex: 4),
              const Text(
                'Вход',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 18),
              _RoundedField(
                controller: _backendController,
                focusNode: _backendFocusNode,
                hintText: 'Backend (ip:port)',
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _loginFocusNode.requestFocus(),
              ),
              const SizedBox(height: 8),
              _RoundedField(
                controller: _loginController,
                focusNode: _loginFocusNode,
                hintText: 'Логин',
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _passwordFocusNode.requestFocus(),
              ),
              const SizedBox(height: 8),
              _RoundedField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                hintText: 'Пароль',
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 122,
                height: 34,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF6FA8FF),
                    disabledBackgroundColor: const Color(0xFF9DC2FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Войти',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Забыли пароль?',
                  style: TextStyle(fontSize: 11, color: Color(0xFF7DA9E8)),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFB64040),
                    fontSize: 12,
                  ),
                ),
              ],
              const Spacer(flex: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Нет аккаунта?', style: TextStyle(fontSize: 11)),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => RegisterScreen(
                                    initialBackendHostPort:
                                        _backendController.text,
                                  ),
                                ),
                              );
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Зарегистрируйтесь',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7DA9E8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  const _RoundedField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.obscureText = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7E7),
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        enableSuggestions: !obscureText,
        autocorrect: !obscureText,
        showCursor: true,
        readOnly: false,
        onTap: () => focusNode.requestFocus(),
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 12, color: Colors.black),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF8C8C8C)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
