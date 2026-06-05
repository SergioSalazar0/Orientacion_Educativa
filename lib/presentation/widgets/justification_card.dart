import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/entities/justification.dart';

/// Card para justificante de ausencia.
class JustificationCard extends StatelessWidget {
  const JustificationCard({
    super.key,
    required this.justification,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
    this.showActions = false,
  });

  final Justification justification;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;
  final bool showActions;

  Color _getStatusColor(BuildContext context, JustificationStatus status) {
    return switch (status) {
      JustificationStatus.aprobado => Colors.green,
      JustificationStatus.rechazado => Colors.red,
      JustificationStatus.pendiente => Colors.orange,
    };
  }

  IconData _getStatusIcon(JustificationStatus status) {
    return switch (status) {
      JustificationStatus.aprobado => Symbols.check_circle,
      JustificationStatus.rechazado => Symbols.cancel,
      JustificationStatus.pendiente => Symbols.pending,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(justification.status),
                    color: _getStatusColor(context, justification.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    justification.status.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(context, justification.status),
                        ),
                  ),
                  const Spacer(),
                  if (justification.createdAt != null)
                    Text(
                      DateFormat('d MMM yyyy', 'es_MX')
                          .format(justification.createdAt!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Symbols.calendar_today,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('d MMMM yyyy', 'es_MX')
                        .format(justification.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                justification.reason,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (justification.description != null) ...[
                const SizedBox(height: 6),
                Text(
                  justification.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (justification.fileUrl != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Symbols.attachment,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Comprobante adjunto',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ],
              if (showActions) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Symbols.edit, size: 18),
                      label: const Text('Editar'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Symbols.delete_outline, size: 18),
                      label: const Text('Eliminar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 70))
        .fadeIn()
        .slideY(begin: 0.1);
  }
}
