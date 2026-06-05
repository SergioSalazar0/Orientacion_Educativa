import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/appointment.dart';

part 'appointment_model.g.dart';

@JsonSerializable()
class AppointmentModel {
  const AppointmentModel({
    required this.id,
    @JsonKey(name: 'student_id') required this.studentId,
    @JsonKey(name: 'guardian_name') required this.guardianName,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
    this.notes,
    @JsonKey(name: 'orientador_id') this.orientadorId,
    @JsonKey(name: 'created_by') this.createdBy,
    @JsonKey(name: 'read_at') this.readAt,
    @JsonKey(name: 'created_at') this.createdAt,
    // join con students para mostrar nombre
    this.students,
  });

  final String id;
  final String studentId;
  final String guardianName;
  final String date;
  final String time;
  final String reason;
  final String status;
  final String? notes;
  final String? orientadorId;
  final String? createdBy;
  final String? readAt;
  final String? createdAt;
  final Map<String, dynamic>? students;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  Appointment toEntity() => Appointment(
        id: id,
        studentId: studentId,
        guardianName: guardianName,
        date: DateTime.parse(date),
        time: time,
        reason: _parseReason(reason),
        status: _parseStatus(status),
        studentName: students?['full_name'] as String?,
        notes: notes,
        orientadorId: orientadorId,
        createdBy: createdBy,
        readAt: readAt != null ? DateTime.tryParse(readAt!) : null,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );

  factory AppointmentModel.fromEntity(Appointment a) => AppointmentModel(
        id: a.id,
        studentId: a.studentId,
        guardianName: a.guardianName,
        date: a.date.toIso8601String().substring(0, 10),
        time: a.time,
        reason: a.reason.name,
        status: a.status.name,
        notes: a.notes,
        orientadorId: a.orientadorId,
        createdBy: a.createdBy,
        readAt: a.readAt?.toIso8601String(),
        createdAt: a.createdAt?.toIso8601String(),
      );

  Map<String, dynamic> toJsonForInsert() {
    final json = toJson();
    json.remove('id');
    json.remove('students');
    json.remove('read_at'); // No se asigna al crear
    // Remover TODOS los nulls (created_at se generará automáticamente)
    json.removeWhere((key, value) => value == null);
    return json;
  }

  static AppointmentReason _parseReason(String s) => switch (s) {
        'vocacional' => AppointmentReason.vocacional,
        'academico' => AppointmentReason.academico,
        'personal' => AppointmentReason.personal,
        _ => AppointmentReason.seguimiento,
      };

  static AppointmentStatus _parseStatus(String s) => switch (s) {
        'confirmada' => AppointmentStatus.confirmada,
        'cancelada' => AppointmentStatus.cancelada,
        _ => AppointmentStatus.programada,
      };
}
