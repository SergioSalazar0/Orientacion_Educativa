import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../viewmodels/justification_viewmodel.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/justification_card.dart';
import '../../widgets/shimmer_loader.dart';

class JustificationsHistoryScreen extends ConsumerWidget {
  const JustificationsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final justificationsAsync = ref.watch(allJustificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Justificantes')),
      body: Column(
        children: [
          justificationsAsync.when(
            loading: () => const Expanded(child: ShimmerLoader()),
            error: (e, _) => Expanded(child: Center(child: Text('Error: $e'))),
            data: (justifications) {
              if (justifications.isEmpty) {
                return const Expanded(
                  child: EmptyState(
                    icon: Symbols.verified_user,
                    title: 'Sin justificantes',
                    subtitle: 'Crea un justificante desde el perfil de un alumno',
                  ),
                );
              }

              final approved =
                  justifications.where((j) => j.status.name == 'aprobado');
              final rejected =
                  justifications.where((j) => j.status.name == 'rechazado');
              final pending =
                  justifications.where((j) => j.status.name == 'pendiente');

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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Resumen de Justificantes',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                          Text(
                                            '${justifications.length}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Aprobados',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Colors.green,
                                                ),
                                          ),
                                          Text(
                                            '${approved.length}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.green,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Rechazados',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Colors.red,
                                                ),
                                          ),
                                          Text(
                                            '${rejected.length}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.red,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pendientes',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Colors.orange,
                                                ),
                                          ),
                                          Text(
                                            '${pending.length}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.orange,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Symbols.verified_user,
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
                        itemCount: justifications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) => JustificationCard(
                          justification: justifications[i],
                          index: i,
                          showActions: true,
                          onEdit: () => context.push(
                            AppRoutes.justificationEdit
                                .replaceFirst(':justificationId', justifications[i].id)
                                .replaceFirst(':studentId', justifications[i].studentId),
                          ),
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar Justificante'),
                                content: const Text('¿Está seguro que desea eliminar este justificante?'),
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
                                  .read(justificationViewModelProvider.notifier)
                                  .delete(justifications[i].id, justifications[i].studentId);
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
