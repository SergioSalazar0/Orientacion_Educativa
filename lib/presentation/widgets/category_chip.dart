import 'package:flutter/material.dart';

import '../../domain/entities/report.dart';

/// Chip de categoría de reporte con color según tipo.
class CategoryChip extends StatelessWidget {
  const CategoryChip(this.category, {super.key});

  final ReportCategory category;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (category) {
      ReportCategory.conducta => (
          'Conducta',
          const Color(0xFFD97706),
          const Color(0xFFFEF3C7),
        ),
      ReportCategory.rendimiento => (
          'Rendimiento',
          const Color(0xFF2563EB),
          const Color(0xFFDBEAFE),
        ),
      ReportCategory.asistencia => (
          'Asistencia',
          const Color(0xFF64748B),
          const Color(0xFFF1F5F9),
        ),
      ReportCategory.otro => (
          'Otro',
          const Color(0xFF7C3AED),
          const Color(0xFFEDE9FE),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
