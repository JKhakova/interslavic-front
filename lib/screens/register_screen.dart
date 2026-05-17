import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.initialBackendHostPort});

  final String initialBackendHostPort;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _backendController;
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _backendFocusNode = FocusNode();
  final FocusNode _fullnameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _loginFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _backendController = TextEditingController(
      text: widget.initialBackendHostPort,
    );
  }

  @override
  void dispose() {
    _backendController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _backendFocusNode.dispose();
    _fullnameFocusNode.dispose();
    _emailFocusNode.dispose();
    _loginFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final success = await context.read<AuthProvider>().register(
      backendHostPort: _backendController.text,
      fullname: _fullnameController.text,
      email: _emailController.text,
      login: _loginController.text,
      password: _passwordController.text,
    );

    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Регистрация успешна. Теперь войдите в аккаунт.'),
      ),
    );
    Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('Регистрация')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            children: [
              _RoundedField(
                controller: _backendController,
                focusNode: _backendFocusNode,
                hintText: 'Backend (ip:port)',
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _fullnameFocusNode.requestFocus(),
              ),
              const SizedBox(height: 8),
              _RoundedField(
                controller: _fullnameController,
                focusNode: _fullnameFocusNode,
                hintText: 'Полное имя',
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _emailFocusNode.requestFocus(),
              ),
              const SizedBox(height: 8),
              _RoundedField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                hintText: 'Email',
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
              const SizedBox(height: 16),
              SizedBox(
                width: 180,
                height: 38,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Отправить'),
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
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7E7),
        borderRadius: BorderRadius.circular(7),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        enableSuggestions: !obscureText,
        autocorrect: !obscureText,
        onTap: () => focusNode.requestFocus(),
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
