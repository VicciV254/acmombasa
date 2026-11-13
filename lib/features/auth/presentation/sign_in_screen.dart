import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/auth_repository.dart';
import '../../../core/domain/app_exception.dart';
import '../../../core/providers.dart';
import '../../splash/presentation/widgets/logo_area.dart';
import '../../splash/presentation/widgets/splash_background.dart';

enum AuthMode {
  /// Normal staff sign-in.
  signIn,

  /// First run: create the administrator account.
  setup,
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({
    super.key,
    required this.mode,
    required this.onSignedIn,
  });

  final AuthMode mode;

  /// Called after a successful sign-in or setup.
  final void Function(BuildContext context) onSignedIn;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  bool get _isSetup => widget.mode == AuthMode.setup;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final session = ref.read(sessionProvider.notifier);
    try {
      if (_isSetup) {
        await session.createFirstAdmin(
          displayName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await session.signIn(
          _emailController.text,
          _passwordController.text,
        );
      }
      if (!mounted) return;
      widget.onSignedIn(context);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SplashBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LogoArea(size: 96),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.splashTitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isSetup ? 'Set up this terminal' : 'Staff sign in',
              style: AppTextStyles.pageTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _isSetup
                  ? 'Create the administrator account. You can add '
                      'receptionist accounts afterwards.'
                  : 'Reception Console',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_isSetup) ...[
              TextFormField(
                controller: _nameController,
                enabled: !_loading,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration('Full name', Icons.person_outline),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name.' : null,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            TextFormField(
              controller: _emailController,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              decoration: _decoration('Email', Icons.mail_outline),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Enter your email address.';
                if (!v.contains('@')) return 'Enter a valid email address.';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              enabled: !_loading,
              obscureText: _obscurePassword,
              textInputAction:
                  _isSetup ? TextInputAction.next : TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) {
                if (!_isSetup) _submit();
              },
              decoration: _decoration('Password', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password.';
                }
                if (_isSetup && value.length < AuthRepository.minPasswordLength) {
                  return 'Use at least ${AuthRepository.minPasswordLength} '
                      'characters.';
                }
                return null;
              },
            ),
            if (_isSetup) ...[
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _confirmController,
                enabled: !_loading,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration:
                    _decoration('Confirm password', Icons.lock_reset_outlined),
                validator: (v) => v != _passwordController.text
                    ? 'Passwords do not match.'
                    : null,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 4),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 18, color: AppColors.americanRed),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.americanRed),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(_isSetup ? 'CREATE ACCOUNT' : 'SIGN IN'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: color),
        );

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: border(AppColors.borderStrong),
      enabledBorder: border(AppColors.borderStrong),
      focusedBorder: border(AppColors.brightBlue),
    );
  }
}
