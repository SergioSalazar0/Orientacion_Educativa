import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/report.dart';

part 'report_model.g.dart';

@JsonSerializable()
class ReportModel {
  const ReportModel({
    required this.id,
    @JsonKey(name: 'student_id') required this.studentId,
    required this.category,
    required this.title,
    required this.description,
    @JsonKey(name: 'image_url') this.imageUrl,
    @JsonKey(name: 'created_by') this.createdBy,
    @JsonKey(name: 'created_at') this.createdAt,
    // join con profiles para mostrar el nombre del orientador
    this.profiles,
  });

  final String id;
  final String studentId;
  final String category;
  final String title;
  final String description;
  final String? imageUrl;
  final String? createdBy;
  final String? createdAt;
  final Map<String, dynamic>? profiles;

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportModelToJson(this);

  Report toEntity() => Report(
        id: id,
        studentId: studentId,
        category: _parseCategory(category),
        title: title,
        description: description,
        imageUrl: imageUrl,
        createdBy: createdBy,
        createdByName: profiles?['full_name'] as String?,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );

  factory ReportModel.fromEntity(Report r) => ReportModel(
        id: r.id,
        studentId: r.studentId,
        category: r.category.name,
        title: r.title,
        description: r.description,
        imageUrl: r.imageUrl,
        createdBy: r.createdBy,
        createdAt: r.createdAt?.toIso8601String(),
      );

  Map<String, dynamic> toJsonForInsert() {
    final json = toJson();
    json.remove('id');
    json.remove('profiles');
    // Remover TODOS los nulls (created_at se generará automáticamente)
    json.removeWhere((key, value) => value == null);
    return json;
  }

  static ReportCategory _parseCategory(String s) => switch (s) {
        'conducta' => ReportCategory.conducta,
        'rendimiento' => ReportCategory.rendimiento,
        'asistencia' => ReportCategory.asistencia,
        _ => ReportCategory.otro,
      };
}
