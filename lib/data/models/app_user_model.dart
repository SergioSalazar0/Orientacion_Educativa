import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/app_user.dart';

part 'app_user_model.g.dart';

@JsonSerializable()
class AppUserModel {
  const AppUserModel({
    required this.id,
    required this.email,
    @JsonKey(name: 'full_name') required this.fullName,
    required this.role,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? avatarUrl;

  factory AppUserModel.fromJson(Map<String, dynamic> json) =>
      _$AppUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppUserModelToJson(this);

  AppUser toEntity() => AppUser(
        id: id,
        email: email,
        fullName: fullName,
        role: role == 'orientador' ? UserRole.orientador : UserRole.padre,
        avatarUrl: avatarUrl,
      );

  factory AppUserModel.fromEntity(AppUser user) => AppUserModel(
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role == UserRole.orientador ? 'orientador' : 'padre',
        avatarUrl: user.avatarUrl,
      );
}
