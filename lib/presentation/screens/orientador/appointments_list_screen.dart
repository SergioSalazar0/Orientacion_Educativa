import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../viewmodels/appointment_viewmodel.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loader.dart';

class AppointmentsListScreen extends ConsumerWidget {
  const AppointmentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Citas')),
      body: appointmentsAsync.when(
        loading: () => const ShimmerLoader(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (appointments) => appointments.isEmpty
            ? EmptyState(
                icon: Symbols.calendar_month,
                title: 'Sin citas programadas',
                actionLabel: 'Agendar cita',
                onAction: () => context.push(AppRoutes.appointmentNew),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => AppointmentCard(
                  appointment: appointments[i],
                  index: i,
                  onTap: () {
                    // Appointment detail view - currently just shows in snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cita con ${appointments[i].studentName} - ${appointments[i].time}',
                        ),
                      ),
                    );
                  },
                ).animate(delay: Duration(milliseconds: i * 40)).fadeIn(),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.appointmentNew),
        icon: const Icon(Symbols.add),
        label: const Text('Nueva cita'),
      ).animate().scale(delay: 300.ms),
      bottomNavigationBar: const OrientadorBottomNav(currentIndex: 1),
    );
  }
}
