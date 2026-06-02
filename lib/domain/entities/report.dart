/// Categoría del reporte de orientación.
enum ReportCategory { conducta, rendimiento, asistencia, otro }

extension ReportCategoryLabel on ReportCategory {
  String get label {
    return switch (this) {
      ReportCategory.conducta => 'Conducta',
      ReportCategory.rendimiento => 'Rendimiento Académico',
      ReportCategory.asistencia => 'Asistencia',
      ReportCategory.otro => 'Otro',
    };
  }
}

/// Reporte de orientación educativa sobre un alumno.
class Report {
  const Report({
    required this.id,
    required this.studentId,
    required this.category,
    required this.title,
    required this.description,
    this.imageUrl,
    this.createdBy,
    this.createdByName,
    this.createdAt,
  });

  final String id;
  final String studentId;
  final ReportCategory category;
  final String title;
  final String description;
  final String? imageUrl;
  final String? createdBy;
  final String? createdByName;
  final DateTime? createdAt;
}
