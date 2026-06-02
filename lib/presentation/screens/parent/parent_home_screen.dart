import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../viewmodels/justification_viewmodel.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/avatar_image.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/status_badge.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orientación Educativa'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Symbols.notifications),
            onPressed: () => context.push(AppRoutes.parentAppointments),
          ),
        ],
      ),
      body: studentsAsync.when(
        loading: () => const ShimmerLoader(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) {
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Symbols.link_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No tienes alumnos vinculados'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.linkChild),
                    icon: const Icon(Symbols.link),
                    label: const Text('Vincular a mi hijo/a'),
                  ),
                ],
              ),
            );
          }

          final student = students.first;
          return ListView(
            children: [
              // Perfil del alumno
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.childProfile),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          AvatarImage(
                            url: student.photoUrl,
                            name: student.fullName,
                            radius: 36,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    _InfoChip(student.semesterGroup),
                                    _InfoChip('ID: ${student.studentCode}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(),

              // Justificantes recientes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Justificantes Recientes',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.push(AppRoutes.parentJustifications),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),
              _JustificationsPreview(studentId: student.id),

              // Reportes
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reportes de Orientación',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.parentReports),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 0),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _JustificationsPreview extends ConsumerWidget {
  const _JustificationsPreview({required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final justificationsAsync =
        ref.watch(justificationsStreamProvider(studentId));

    return justificationsAsync.when(
      loading: () => const ShimmerLoader(itemCount: 2),
      error: (e, _) => Text('Error: $e'),
      data: (items) => items.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin justificantes recientes.'),
            )
          : Column(
              children: items.take(3).map((j) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Symbols.description,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(j.reason),
                      subtitle: Text(
                        DateFormat('d MMM yyyy', 'es_MX').format(j.date),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: StatusBadge.justification(j.status),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
