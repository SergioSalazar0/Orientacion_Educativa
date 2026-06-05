import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../viewmodels/justification_viewmodel.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/status_badge.dart';

class ParentJustificationsScreen extends ConsumerWidget {
  const ParentJustificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Justificantes'), centerTitle: true),
      body: studentsAsync.when(
        loading: () => const ShimmerLoader(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('Sin alumnos vinculados'));
          }
          return _JustificationsList(studentId: students.first.id);
        },
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 2),
    );
  }
}

class _JustificationsList extends ConsumerWidget {
  const _JustificationsList({required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(justificationsStreamProvider(studentId));

    return async.when(
      loading: () => const ShimmerLoader(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (items) => items.isEmpty
          ? const EmptyState(
              icon: Symbols.assignment_turned_in,
              title: 'Sin justificantes',
              subtitle: 'No hay justificantes registrados aún',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final j = items[i];
                return Card(
                  child: ListTile(
                     onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text('Justificante: ${j.reason}'),
                         duration: const Duration(seconds: 2),
                       ),
                     ),
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
                    title: Text(j.reason,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      DateFormat('d MMM yyyy', 'es_MX').format(j.date),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: StatusBadge.justification(j.status),
                  ),
                )
                    .animate(delay: Duration(milliseconds: i * 50))
                    .fadeIn()
                    .slideX(begin: 0.05);
              },
            ),
    );
  }
}

