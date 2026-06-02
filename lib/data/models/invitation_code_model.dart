import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/invitation_code.dart';

part 'invitation_code_model.g.dart';

@JsonSerializable()
class InvitationCodeModel {
  const InvitationCodeModel({
    required this.id,
    required this.code,
    @JsonKey(name: 'student_id') required this.studentId,
    @JsonKey(name: 'expires_at') required this.expiresAt,
    @JsonKey(name: 'used_by') this.usedBy,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  final String id;
  final String code;
  final String studentId;
  final String expiresAt;
  final String? usedBy;
  final String? createdAt;

  factory InvitationCodeModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationCodeModelFromJson(json);
  Map<String, dynamic> toJson() => _$InvitationCodeModelToJson(this);

  InvitationCode toEntity() => InvitationCode(
        id: id,
        code: code,
        studentId: studentId,
        expiresAt: DateTime.parse(expiresAt),
        usedBy: usedBy,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );
}
