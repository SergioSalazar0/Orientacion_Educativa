import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/report_card.dart';
import '../../widgets/shimmer_loader.dart';

class ReportsHistoryScreen extends ConsumerWidget {
  const ReportsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Reportes')),
      body: Column(
        children: [
          reportsAsync.when(
            loading: () => const Expanded(child: ShimmerLoader()),
            error: (e, _) => Expanded(child: Center(child: Text('Error: $e'))),
            data: (reports) {
              if (reports.isEmpty) {
                return const Expanded(
                  child: EmptyState(
                    icon: Symbols.description,
                    title: 'Sin reportes',
                    subtitle: 'Crea un reporte desde el perfil de un alumno',
                  ),
                );
              }

              return Expanded(
                child: Column(
                  children: [
                    // Resumen
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resumen de Orientación',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total: ${reports.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Symbols.assignment_late,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(),

                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: reports.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) => ReportCard(
                          report: reports[i],
                          index: i,
                          showActions: true,
                          onEdit: () => context.push(
                            AppRoutes.reportEdit
                                .replaceFirst(':reportId', reports[i].id)
                                .replaceFirst(':studentId', reports[i].studentId),
                          ),
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar Reporte'),
                                content: const Text('¿Está seguro que desea eliminar este reporte?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              await ref
                                  .read(reportViewModelProvider.notifier)
                                  .delete(reports[i].id, reports[i].studentId);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const OrientadorBottomNav(currentIndex: 3),
    );
  }
}
