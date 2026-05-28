import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_input.dart';
import '../../state/auth_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registerMode = false;
  String _role = 'user';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.x3),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 56,
                        color: AppColors.brandStrong,
                      ),
                      const SizedBox(height: 8),
                      const Text('Scout',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 34, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Geo-Tag',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.x4),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(_registerMode ? 'Create account' : 'Sign in',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800)),
                            const SizedBox(height: AppSpacing.x2),
                            if (_registerMode) ...[
                              AppInput(label: 'Your Name', controller: _name),
                              const SizedBox(height: AppSpacing.x2),
                            ],
                            AppInput(label: 'Email', controller: _email),
                            const SizedBox(height: AppSpacing.x2),
                            AppInput(
                                label: 'Password',
                                controller: _password,
                                obscureText: true),
                            if (_registerMode) ...[
                              const SizedBox(height: AppSpacing.x2),
                              DropdownButtonFormField<String>(
                                initialValue: _role,
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                                dropdownColor: AppColors.surface,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'user', child: Text('User')),
                                  DropdownMenuItem(
                                      value: 'admin', child: Text('Admin')),
                                ],
                                onChanged: (v) =>
                                    setState(() => _role = v ?? 'user'),
                                decoration:
                                    const InputDecoration(labelText: 'Role'),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.x2),
                            AppButton(
                              label: auth.loading
                                  ? 'Please wait...'
                                  : _registerMode
                                      ? 'Create Account'
                                      : 'Sign In',
                              icon: _registerMode
                                  ? Icons.person_add_alt_1
                                  : Icons.login,
                              onPressed: auth.loading
                                  ? null
                                  : () async {
                                      if (_registerMode) {
                                        final orgId = _email.text.contains('@')
                                            ? _email.text.split('@').last
                                            : 'default';
                                        await context
                                            .read<AuthState>()
                                            .register(
                                              _email.text.trim(),
                                              _password.text,
                                              orgId,
                                              _role,
                                            );
                                      } else {
                                        await context.read<AuthState>().login(
                                              _email.text.trim(),
                                              _password.text,
                                            );
                                      }
                                    },
                            ),
                            if (auth.error != null) ...[
                              const SizedBox(height: AppSpacing.x2),
                              Text(
                                auth.error!,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              ),
                            ],
                            if (auth.notice != null) ...[
                              const SizedBox(height: AppSpacing.x2),
                              Text(
                                auth.notice!,
                                style:
                                    const TextStyle(color: AppColors.success),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.x2),
                            TextButton(
                              onPressed: () => setState(
                                  () => _registerMode = !_registerMode),
                              child: Text(_registerMode
                                  ? 'Have an account? Sign In'
                                  : 'New to Scout? Create account'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
