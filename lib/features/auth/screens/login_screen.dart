import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_colors.dart';
import '../../../app/router.dart';
import '../../../core/widgets/field_label.dart';
import '../../../core/widgets/lumi_mascot.dart';
import '../controllers/login_controller.dart';
import 'auth_mode_tabs.dart';

/// Parent log in and sign up with email and password (design p3, FR-AUTH-01).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Submit the form ──
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final controller = ref.read(loginControllerProvider.notifier);
    if (_isSignUp) {
      await controller.signUp(_emailController.text, _passwordController.text);
    } else {
      await controller.logIn(_emailController.text, _passwordController.text);
    }
    if (mounted && !ref.read(loginControllerProvider).hasError) {
      context.go(_isSignUp ? AppRoutes.addChild : AppRoutes.parentHome);
    }
  }

  // ── Forgot password ──
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Type your email first, then tap "Forgot password?".');
      return;
    }
    final sent = await ref
        .read(loginControllerProvider.notifier)
        .sendPasswordReset(email);
    if (sent) {
      _showMessage('We sent a reset link to $email.');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // ── Field checks ──
  String? _checkEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Please type your email.';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'That email does not look right.';
    }
    return null;
  }

  String? _checkPassword(String? value) {
    if ((value ?? '').length < 6) {
      return 'Password needs at least 6 characters.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final loginState = ref.watch(loginControllerProvider);
    final isLoading = loginState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                const Center(child: LumiMascot(size: 72)),
                const SizedBox(height: 16),
                Text(
                  'Welcome, grown-up!',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  "Sign in to create stories and follow your child's reading.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                AuthModeTabs(
                  isSignUp: _isSignUp,
                  onChanged: (value) => setState(() => _isSignUp = value),
                ),
                const SizedBox(height: 24),

                // ── Email and password fields ──
                const FieldLabel('EMAIL'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: _checkEmail,
                ),
                const SizedBox(height: 16),
                const FieldLabel('PASSWORD'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: _checkPassword,
                ),
                if (!_isSignUp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : _forgotPassword,
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(color: colors.primary),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // ── Error message with retry ──
                if (loginState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      loginState.error.toString(),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.coralSoft,
                      ),
                    ),
                  ),

                // ── Main button ──
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(_isSignUp ? 'Create account' : 'Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
