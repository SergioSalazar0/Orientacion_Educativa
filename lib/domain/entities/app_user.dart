/// Rol del usuario en la aplicación.
enum UserRole { orientador, padre }

/// Objeto de negocio puro: representa al usuario autenticado.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;

  bool get isOrientador => role == UserRole.orientador;
  bool get isPadre => role == UserRole.padre;

  AppUser copyWith({
    String? fullName,
    UserRole? role,
    String? avatarUrl,
  }) =>
      AppUser(
        id: id,
        email: email,
        fullName: fullName ?? this.fullName,
        role: role ?? this.role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}
