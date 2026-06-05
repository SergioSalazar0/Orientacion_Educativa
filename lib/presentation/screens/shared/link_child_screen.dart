import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// Pantalla para que el padre ingrese el código de invitación y se vincule
/// con el alumno. Se muestra después del registro si el padre no tiene hijos vinculados.
class LinkChildScreen extends ConsumerStatefulWidget {
  const LinkChildScreen({super.key});

  @override
  ConsumerState<LinkChildScreen> createState() => _LinkChildScreenState();
}

class _LinkChildScreenState extends ConsumerState<LinkChildScreen> {
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authViewModelProvider.notifier)
        .redeemInvitationCode(_codeCtrl.text.trim().toUpperCase());
    if (ok && mounted) {
      context.go(AppRoutes.parentHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Vincular a mi hijo/a')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Symbols.link, size: 40, color: primary),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Ingresa el código que tu hijo/a comparte contigo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              Text(
                'El orientador generó este código único que puedes reutilizar las veces que necesites para vincular el perfil de tu hijo/a.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Código de invitación',
                controller: _codeCtrl,
                hint: 'Ej. A1B2C3D4',
                prefixIcon: Symbols.vpn_key,
                validator: (v) => (v == null || v.length < 6)
                    ? 'Ingresa el código completo'
                    : null,
              ).animate().fadeIn(delay: 300.ms),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.errorMessage!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13),
                ).animate().shake(),
              ],
              const SizedBox(height: 32),
              AppButton(
                label: 'Vincular',
                icon: Symbols.link,
                isLoading: state.isLoading,
                onPressed: _submit,
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
