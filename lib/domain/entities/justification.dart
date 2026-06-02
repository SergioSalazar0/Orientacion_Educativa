/// Estado del justificante.
enum JustificationStatus { pendiente, aprobado, rechazado }

extension JustificationStatusLabel on JustificationStatus {
  String get label => switch (this) {
        JustificationStatus.pendiente => 'Pendiente',
        JustificationStatus.aprobado => 'Aprobado',
        JustificationStatus.rechazado => 'Rechazado',
      };
}

/// Justificante de ausencia de un alumno.
class Justification {
  const Justification({
    required this.id,
    required this.studentId,
    required this.reason,
    required this.date,
    required this.status,
    this.description,
    this.fileUrl,
    this.createdBy,
    this.reviewedBy,
    this.createdAt,
  });

  final String id;
  final String studentId;
  final String reason;
  final DateTime date;
  final JustificationStatus status;
  final String? description;
  final String? fileUrl;
  final String? createdBy;
  final String? reviewedBy;
  final DateTime? createdAt;
}
