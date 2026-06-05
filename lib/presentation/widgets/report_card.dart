import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/report.dart';
import 'category_chip.dart';

/// Card de reporte con imagen de cabecera y chip de categoría.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
    this.showActions = false,
  });

  final Report report;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.imageUrl != null)
              SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.network(
                  report.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CategoryChip(report.category),
                      const Spacer(),
                      if (report.createdAt != null)
                        Text(
                          DateFormat('d MMM yyyy', 'es_MX')
                              .format(report.createdAt!),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.4),
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (report.createdByName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          report.createdByName!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 70))
        .fadeIn()
        .slideY(begin: 0.1);
  }
}

