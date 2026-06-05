import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../viewmodels/report_viewmodel.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/report_card.dart';
import '../../widgets/shimmer_loader.dart';

class ParentReportsScreen extends ConsumerWidget {
  const ParentReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes de Orientación'), centerTitle: true),
      body: studentsAsync.when(
        loading: () => const ShimmerLoader(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('Sin alumnos vinculados'));
          }
          return _ReportsList(studentId: students.first.id);
        },
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 1),
    );
  }
}

class _ReportsList extends ConsumerWidget {
  const _ReportsList({required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsStreamProvider(studentId));

    return reportsAsync.when(
      loading: () => const ShimmerLoader(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (reports) => reports.isEmpty
          ? const EmptyState(
              icon: Symbols.description,
              title: 'Sin reportes',
              subtitle: 'El orientador no ha generado reportes aún',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => ReportCard(
                    report: reports[i],
                    index: i,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reporte: ${reports[i].title}'),
                        duration: const Duration(seconds: 2),
                      ),
                    ),
                  ),
            ),
    );
  }
}
