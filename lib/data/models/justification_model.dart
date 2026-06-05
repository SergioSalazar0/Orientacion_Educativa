import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/justification.dart';

part 'justification_model.g.dart';

@JsonSerializable()
class JustificationModel {
  const JustificationModel({
    required this.id,
    @JsonKey(name: 'student_id') required this.studentId,
    required this.reason,
    required this.date,
    required this.status,
    this.description,
    @JsonKey(name: 'file_url') this.fileUrl,
    @JsonKey(name: 'created_by') this.createdBy,
    @JsonKey(name: 'reviewed_by') this.reviewedBy,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  final String id;
  final String studentId;
  final String reason;
  final String date;
  final String status;
  final String? description;
  final String? fileUrl;
  final String? createdBy;
  final String? reviewedBy;
  final String? createdAt;

  factory JustificationModel.fromJson(Map<String, dynamic> json) =>
      _$JustificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$JustificationModelToJson(this);

  Justification toEntity() => Justification(
        id: id,
        studentId: studentId,
        reason: reason,
        date: DateTime.parse(date),
        status: _parseStatus(status),
        description: description,
        fileUrl: fileUrl,
        createdBy: createdBy,
        reviewedBy: reviewedBy,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );

  factory JustificationModel.fromEntity(Justification j) => JustificationModel(
        id: j.id,
        studentId: j.studentId,
        reason: j.reason,
        date: j.date.toIso8601String().substring(0, 10),
        status: j.status.name,
        description: j.description,
        fileUrl: j.fileUrl,
        createdBy: j.createdBy,
        reviewedBy: j.reviewedBy,
        createdAt: j.createdAt?.toIso8601String(),
      );

  Map<String, dynamic> toJsonForInsert() {
    final json = toJson();
    json.remove('id');
    json.remove('reviewed_by'); // No se asigna al crear
    // Remover TODOS los nulls (created_at se generará automáticamente)
    json.removeWhere((key, value) => value == null);
    return json;
  }

  static JustificationStatus _parseStatus(String s) => switch (s) {
        'aprobado' => JustificationStatus.aprobado,
        'rechazado' => JustificationStatus.rechazado,
        _ => JustificationStatus.pendiente,
      };
}
