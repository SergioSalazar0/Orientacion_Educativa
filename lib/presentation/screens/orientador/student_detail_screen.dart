import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../viewmodels/justification_viewmodel.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../widgets/avatar_image.dart';
import '../../widgets/report_card.dart';
import '../../widgets/justification_card.dart';
import '../../widgets/shimmer_loader.dart';

class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentDetailProvider(studentId));
    final guardiansAsync = ref.watch(studentGuardiansProvider(studentId));
    final reportsAsync = ref.watch(reportsStreamProvider(studentId));
    final justificationsAsync = ref.watch(justificationsStreamProvider(studentId));
    final invitationCodesAsync = ref.watch(invitationCodesProvider(studentId));

    return Scaffold(
      body: studentAsync.when(
        loading: () => const ShimmerLoader(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (student) => CustomScrollView(
          slivers: [
            // App bar con foto
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(student.fullName),
                background: student.photoUrl != null
                    ? Image.network(student.photoUrl!, fit: BoxFit.cover)
                    : Container(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                        child: Center(
                          child: AvatarImage(
                            name: student.fullName,
                            radius: 48,
                          ),
                        ),
                      ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Symbols.edit),
                  onPressed: () => context.push(
                    AppRoutes.studentEdit.replaceFirst(':id', studentId),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info académica
                    const _SectionTitle('Información Académica').animate().fadeIn(),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _InfoRow('Matrícula', student.studentCode),
                            _InfoRow('Semestre', '${student.semester}°'),
                            _InfoRow('Grupo', student.group),
                            _InfoRow('Especialidad', student.specialty),
                            if (student.birthDate != null)
                              _InfoRow(
                                'Fecha de nacimiento',
                                DateFormat('d MMMM yyyy', 'es_MX')
                                    .format(student.birthDate!),
                              ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 16),

                    // Acciones rápidas
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push(
                              AppRoutes.reportNew
                                  .replaceFirst(':id', studentId),
                            ),
                            icon: const Icon(Symbols.description, size: 18),
                            label: const Text('Reporte'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push(
                              AppRoutes.justificationNew
                                  .replaceFirst(':id', studentId),
                            ),
                            icon: const Icon(Symbols.verified_user, size: 18),
                            label: const Text('Justificante'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.push(
                              '${AppRoutes.appointmentNew}?studentId=$studentId',
                            ),
                            icon: const Icon(Symbols.calendar_month, size: 18),
                            label: const Text('Cita'),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 16),

                    // Tutores
                    const _SectionTitle('Tutores / Contactos').animate().fadeIn(delay: 200.ms),
                    guardiansAsync.when(
                      loading: () => const ShimmerLoader(itemCount: 2),
                      error: (e, _) => Text('Error: $e'),
                      data: (guardians) => guardians.isEmpty
                          ? const Text('Sin tutores registrados.')
                          : Column(
                              children: guardians
                                  .map(
                                    (g) => Card(
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          child: Text(g.fullName[0]),
                                        ),
                                        title: Text(g.fullName),
                                        subtitle: Text(
                                            '${g.relationship} · ${g.phone ?? 'Sin teléfono'}'),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Código de invitación
                    const _SectionTitle('Código de invitación para padres')
                        .animate()
                        .fadeIn(delay: 250.ms),
                    Card(
                      child: ListTile(
                        leading: const Icon(Symbols.vpn_key),
                        title: const Text('Generar nuevo código'),
                        subtitle: const Text(
                            'El padre usa este código para acceder al portal'),
                        trailing: const Icon(Symbols.add_circle),
                        onTap: () async {
                          await ref
                              .read(studentFormViewModelProvider.notifier)
                              .generateInvitationCode(studentId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Código generado exitosamente')),
                            );
                          }
                        },
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    // Listado de códigos generados
                    const SizedBox(height: 12),
                    invitationCodesAsync.when(
                      loading: () => const ShimmerLoader(itemCount: 1),
                      error: (e, _) => Text('Error: $e'),
                      data: (codes) => codes.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Sin códigos generados aún.'),
                            )
                            : Column(
                                children: codes
                                    .map(
                                      (code) => Card(
                                        child: ListTile(
                                          leading: Icon(
                                            Symbols.vpn_key,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          title: Text(
                                            code.code,
                                            style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: const Text(
                                            'Código reutilizable para vincular padres',
                                          ),
                                          trailing: Icon(
                                            Symbols.verified,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                    ),

                    const SizedBox(height: 16),

                    // Reportes recientes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionTitle('Reportes'),
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.reportsHistory),
                          child: const Text('Ver todos'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 350.ms),

                    reportsAsync.when(
                      loading: () => const ShimmerLoader(itemCount: 2),
                      error: (e, _) => Text('Error: $e'),
                      data: (reports) => reports.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Sin reportes aún.'),
                            )
                          : Column(
                              children: reports
                                  .take(3)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: ReportCard(
                                        report: e.value,
                                        index: e.key,
                                        showActions: true,
                                        onEdit: () => context.push(
                                          AppRoutes.reportEdit
                                              .replaceFirst(':reportId', e.value.id)
                                              .replaceFirst(':studentId', studentId),
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
                                                .delete(e.value.id, studentId);
                                          }
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Justificantes recientes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionTitle('Justificantes'),
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.justificationsHistory),
                          child: const Text('Ver todos'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),

                    justificationsAsync.when(
                      loading: () => const ShimmerLoader(itemCount: 2),
                      error: (e, _) => Text('Error: $e'),
                      data: (justifications) => justifications.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Sin justificantes aún.'),
                            )
                          : Column(
                              children: justifications
                                  .take(3)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: JustificationCard(
                                        justification: e.value,
                                        index: e.key,
                                        showActions: true,
                                        onEdit: () => context.push(
                                          AppRoutes.justificationEdit
                                              .replaceFirst(':justificationId', e.value.id)
                                              .replaceFirst(':studentId', studentId),
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
                                                .delete(e.value.id, studentId);
                                          }
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
