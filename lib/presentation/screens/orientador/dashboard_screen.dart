import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../providers/auth_providers.dart';
import '../../viewmodels/appointment_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loader.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final upcomingAsync = ref.watch(upcomingAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Symbols.dashboard,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Dashboard Orientador'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.notifications),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Symbols.account_circle),
            tooltip: 'Perfil',
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authViewModelProvider.notifier).signOut();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Symbols.logout, size: 18),
                    SizedBox(width: 10),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Saludo
          Text(
            'Hola, ${user?.fullName.split(' ').first ?? 'Orientador'} 👋',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: 20),

          // Accesos rápidos
          Text(
            'ACCESOS RÁPIDOS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
            children: [
              _QuickAction(
                icon: Symbols.person_add,
                label: 'Registrar Alumno',
                index: 0,
                onTap: () => context.push(AppRoutes.studentNew),
              ),
              _QuickAction(
                icon: Symbols.description,
                label: 'Crear Reporte',
                index: 1,
                onTap: () => context.push(AppRoutes.studentsList),
              ),
              _QuickAction(
                icon: Symbols.person_remove,
                label: 'Registro de Bajas',
                index: 2,
                onTap: () => context.push(AppRoutes.studentsList),
              ),
              _QuickAction(
                icon: Symbols.verified_user,
                label: 'Justificantes',
                index: 3,
                onTap: () => context.push(AppRoutes.studentsList),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Próximas citas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRÓXIMAS CITAS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.appointmentsList),
                child: const Text('Ver todas'),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 8),

          upcomingAsync.when(
            loading: () => const ShimmerLoader(itemCount: 2),
            error: (e, _) => Text('Error: $e'),
            data: (appointments) => appointments.isEmpty
                ? EmptyState(
                    icon: Symbols.calendar_month,
                    title: 'No hay citas próximas',
                    subtitle: 'Agenda una nueva cita',
                    actionLabel: 'Nueva cita',
                    onAction: () => context.push(AppRoutes.appointmentNew),
                  )
                : Column(
                    children: appointments
                        .take(3)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppointmentCard(
                              appointment: e.value,
                              index: e.key,
                              onTap: () {},
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const OrientadorBottomNav(currentIndex: 0),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.index,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 150 + index * 60))
        .fadeIn()
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }
}
