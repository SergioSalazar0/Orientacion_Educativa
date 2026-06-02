/// Estado de la cita.
enum AppointmentStatus { programada, confirmada, cancelada }

extension AppointmentStatusLabel on AppointmentStatus {
  String get label => switch (this) {
        AppointmentStatus.programada => 'Programada',
        AppointmentStatus.confirmada => 'Confirmada',
        AppointmentStatus.cancelada => 'Cancelada',
      };
}

/// Motivo de la cita con el orientador.
enum AppointmentReason { vocacional, academico, personal, seguimiento }

extension AppointmentReasonLabel on AppointmentReason {
  String get label => switch (this) {
        AppointmentReason.vocacional => 'Vocacional',
        AppointmentReason.academico => 'Académico',
        AppointmentReason.personal => 'Personal',
        AppointmentReason.seguimiento => 'Seguimiento',
      };
}

/// Cita entre el orientador y el padre/tutor de un alumno.
class Appointment {
  const Appointment({
    required this.id,
    required this.studentId,
    required this.guardianName,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
    this.studentName,
    this.notes,
    this.orientadorId,
    this.createdBy,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String studentId;
  final String guardianName;
  final DateTime date;
  final String time;
  final AppointmentReason reason;
  final AppointmentStatus status;
  final String? studentName;
  final String? notes;
  final String? orientadorId;
  final String? createdBy;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;
}
