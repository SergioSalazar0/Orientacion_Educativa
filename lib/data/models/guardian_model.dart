import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/guardian.dart';

part 'guardian_model.g.dart';

@JsonSerializable()
class GuardianModel {
  const GuardianModel({
    required this.id,
    @JsonKey(name: 'student_id') required this.studentId,
    required this.relationship,
    @JsonKey(name: 'full_name') required this.fullName,
    this.phone,
    this.address,
  });

  final String id;
  final String studentId;
  final String relationship;
  final String fullName;
  final String? phone;
  final String? address;

  factory GuardianModel.fromJson(Map<String, dynamic> json) =>
      _$GuardianModelFromJson(json);
  Map<String, dynamic> toJson() => _$GuardianModelToJson(this);

  Guardian toEntity() => Guardian(
        id: id,
        studentId: studentId,
        relationship: relationship,
        fullName: fullName,
        phone: phone,
        address: address,
      );

  factory GuardianModel.fromEntity(Guardian g) => GuardianModel(
        id: g.id,
        studentId: g.studentId,
        relationship: g.relationship,
        fullName: g.fullName,
        phone: g.phone,
        address: g.address,
      );
}
