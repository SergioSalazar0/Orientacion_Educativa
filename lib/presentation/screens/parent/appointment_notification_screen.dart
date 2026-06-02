import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../domain/entities/appointment.dart';
import '../../providers/repository_providers.dart';
import '../../viewmodels/appointment_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/shimmer_loader.dart';

final _appointmentDetailProvider =
    FutureProvider.autoDispose.family<Appointment, String>((ref, id) {
  return ref.watch(appointmentRepositoryProvider).getAppointmentById(id);
});

class AppointmentNotificationScreen extends ConsumerWidget {
  const AppointmentNotificationScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentAsync =
        ref.watch(_appointmentDetailProvider(appointmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificación de Cita'),
        centerTitle: true,
      ),
      body: appointmentAsync.when(
        loading: () => const ShimmerLoader(itemCount: 3),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (appointment) => SingleChildScrollView(
          child: Column(
            children: [
              // Banner de alerta
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 4,
                      ),
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Symbols.notifications_active,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nueva Notificación',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const Text(
                              'Se ha programado una sesión de orientación.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideX(begin: -0.1),

              // Imagen banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: Icon(
                            Symbols.school,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nueva Cita de Orientación',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Se ha programado una sesión de seguimiento para el desarrollo integral de su hijo(a).',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms),

              // Detalles
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Symbols.info,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Detalles de la Cita',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                        icon: Symbols.person,
                        label: 'Alumno',
                        value: appointment.studentName ?? '—'),
                    _DetailRow(
                        icon: Symbols.calendar_today,
                        label: 'Fecha',
                        value: DateFormat('d MMMM yyyy', 'es_MX')
                            .format(appointment.date)),
                    _DetailRow(
                        icon: Symbols.schedule,
                        label: 'Hora',
                        value: appointment.time),
                    _DetailRow(
                        icon: Symbols.article,
                        label: 'Motivo',
                        value: appointment.reason.label),
                    _DetailRow(
                        icon: Symbols.pending_actions,
                        label: 'Estado',
                        value: appointment.status.label),
                    if (appointment.notes != null)
                      _DetailRow(
                          icon: Symbols.notes,
                          label: 'Notas',
                          value: appointment.notes!),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              // Botones de acción
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  children: [
                    if (!appointment.isRead)
                      AppButton(
                        label: 'Confirmar Lectura',
                        icon: Symbols.done_all,
                        onPressed: () async {
                          await ref
                              .read(appointmentViewModelProvider.notifier)
                              .markAsRead(appointment.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Lectura confirmada')),
                            );
                          }
                        },
                      ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 12),
                    if (appointment.status == AppointmentStatus.programada)
                      AppButton(
                        label: 'Confirmar Cita',
                        icon: Symbols.event_available,
                        onPressed: () async {
                          await ref
                              .read(appointmentViewModelProvider.notifier)
                              .updateStatus(
                                  appointment.id, AppointmentStatus.confirmada);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cita confirmada')),
                            );
                            Navigator.pop(context);
                          }
                        },
                      ).animate().fadeIn(delay: 350.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4)),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
