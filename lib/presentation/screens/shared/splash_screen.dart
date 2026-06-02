import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pantalla de carga inicial mientras el router verifica el estado de sesión.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Symbols.school, size: 40, color: primary),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(duration: 1200.ms),
            const SizedBox(height: 24),
            Text(
              'Orientación Educativa',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ).animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: 8),
            Text(
              'CBTIS',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
            ).animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 48),
            const CircularProgressIndicator()
                .animate(delay: 600.ms)
                .fadeIn(),
          ],
        ),
      ),
    );
  }
}
