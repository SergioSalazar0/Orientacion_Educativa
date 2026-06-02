import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authViewModelProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim(),
        );
    if (ok && mounted) {
      // Después del registro, el padre debe vincular a su hijo
      context.go(AppRoutes.linkChild);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Crear Cuenta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Symbols.school, size: 44, color: primary),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 24),
                    Text(
                      'Únete a Orientación Educativa',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 32),

                    AppTextField(
                      label: 'Nombre Completo',
                      controller: _nameCtrl,
                      hint: 'Ej. Juan Pérez',
                      prefixIcon: Symbols.person,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa tu nombre'
                          : null,
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Correo Electrónico',
                      controller: _emailCtrl,
                      hint: 'ejemplo@correo.com',
                      prefixIcon: Symbols.mail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Correo inválido'
                          : null,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Contraseña',
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      prefixIcon: Symbols.lock,
                      isPassword: true,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Confirmar Contraseña',
                      controller: _confirmCtrl,
                      hint: '••••••••',
                      prefixIcon: Symbols.lock_reset,
                      isPassword: true,
                      validator: (v) => v != _passwordCtrl.text
                          ? 'Las contraseñas no coinciden'
                          : null,
                    ).animate().fadeIn(delay: 300.ms),

                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ).animate().shake(),
                    ],

                    const SizedBox(height: 32),

                    AppButton(
                      label: 'Registrarse',
                      icon: Symbols.how_to_reg,
                      isLoading: state.isLoading,
                      onPressed: _submit,
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿Ya tienes cuenta? '),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            'Inicia sesión',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
