import '../entities/app_user.dart';

/// Contrato de autenticación. La implementación concreta usa Supabase Auth
/// pero puede reemplazarse por Firebase sin tocar los ViewModels.
abstract interface class IAuthRepository {
  /// Stream del usuario actual; emite null cuando no hay sesión.
  Stream<AppUser?> get authStateChanges;

  /// Inicia sesión con correo y contraseña.
  Future<AppUser> signIn({required String email, required String password});

  /// Registra una nueva cuenta con correo y contraseña.
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  /// Envía correo de recuperación de contraseña.
  Future<void> sendPasswordReset(String email);

  /// Cierra la sesión activa.
  Future<void> signOut();

  /// Devuelve el usuario actualmente autenticado o null.
  Future<AppUser?> getCurrentUser();

  /// Actualiza el perfil del usuario (nombre, avatar).
  Future<AppUser> updateProfile({String? fullName, String? avatarUrl});

  /// Canjea un código de invitación para vincular padre con alumno.
  /// Retorna el studentId del alumno vinculado.
  Future<String> redeemInvitationCode(String code);
}
