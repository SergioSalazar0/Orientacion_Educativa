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
    if (!mounted) return;
    
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Symbols.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Cuenta creada exitosamente!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      // Después del registro, el padre debe vincular a su hijo
      if (mounted) context.go(AppRoutes.linkChild);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Symbols.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ref.read(authViewModelProvider).errorMessage ?? 'Error al registrar',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
        elevation: 0,
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
                    // Header con icono y animación
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary.withValues(alpha: 0.2), primary.withValues(alpha: 0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Symbols.school, size: 44, color: primary),
                          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                          const SizedBox(height: 16),
                          Text(
                            'Crear tu Cuenta',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 8),
                          Text(
                            'Únete a nuestra plataforma de orientación educativa',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 150.ms),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Campos de formulario
                    AppTextField(
                      label: 'Nombre Completo',
                      controller: _nameCtrl,
                      hint: 'Ej. Juan Pérez López',
                      prefixIcon: Symbols.person,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa tu nombre completo'
                          : null,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 20),

                    AppTextField(
                      label: 'Correo Electrónico',
                      controller: _emailCtrl,
                      hint: 'tu.email@correo.com',
                      prefixIcon: Symbols.mail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Correo inválido'
                          : null,
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 20),

                    AppTextField(
                      label: 'Contraseña',
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      prefixIcon: Symbols.lock,
                      isPassword: true,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 20),

                    AppTextField(
                      label: 'Confirmar Contraseña',
                      controller: _confirmCtrl,
                      hint: '••••••••',
                      prefixIcon: Symbols.lock_reset,
                      isPassword: true,
                      validator: (v) => v != _passwordCtrl.text
                          ? 'Las contraseñas no coinciden'
                          : null,
                    ).animate().fadeIn(delay: 350.ms),

                    // Mensaje de error profesional
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.error,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().shake(),
                    ],

                    const SizedBox(height: 40),

                    // Botón de registro
                    AppButton(
                      label: 'Crear Cuenta',
                      icon: Symbols.how_to_reg,
                      isLoading: state.isLoading,
                      onPressed: _submit,
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 20),

                    // Link a login
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Inicia sesión',
                              style: TextStyle(
                                color: primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 450.ms),
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
