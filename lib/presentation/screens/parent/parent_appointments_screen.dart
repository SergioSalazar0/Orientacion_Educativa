import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../viewmodels/appointment_viewmodel.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loader.dart';

class ParentAppointmentsScreen extends ConsumerWidget {
  const ParentAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Citas'), centerTitle: true),
      body: studentsAsync.when(
        loading: () => const ShimmerLoader(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('Sin alumnos vinculados'));
          }
          return _AppointmentsList(studentId: students.first.id);
        },
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 0),
    );
  }
}

class _AppointmentsList extends ConsumerWidget {
  const _AppointmentsList({required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(studentAppointmentsStreamProvider(studentId));

    return async.when(
      loading: () => const ShimmerLoader(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (appointments) => appointments.isEmpty
          ? const EmptyState(
              icon: Symbols.calendar_month,
              title: 'Sin citas programadas',
              subtitle: 'El orientador agendará una cita cuando sea necesario',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => AppointmentCard(
                appointment: appointments[i],
                index: i,
                onTap: () => context.push(
                  AppRoutes.appointmentNotification.replaceFirst(
                    ':id',
                    appointments[i].id,
                  ),
                ),
              ),
            ),
    );
  }
}
