import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/invitation_code.dart';

part 'invitation_code_model.g.dart';

@JsonSerializable()
class InvitationCodeModel {
  const InvitationCodeModel({
    required this.id,
    required this.code,
    @JsonKey(name: 'student_id') required this.studentId,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  final String id;
  final String code;
  final String studentId;
  final String? createdAt;

  factory InvitationCodeModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationCodeModelFromJson(json);
  Map<String, dynamic> toJson() => _$InvitationCodeModelToJson(this);

  InvitationCode toEntity() => InvitationCode(
        id: id,
        code: code,
        studentId: studentId,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );
}
