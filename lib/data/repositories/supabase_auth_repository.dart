import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/app_user_model.dart';

/// Implementación concreta de [IAuthRepository] usando Supabase Auth.
/// Para cambiar a Firebase basta con crear SupabaseAuthRepository análogo
/// e intercambiar el provider de DI en presentation/providers.
class SupabaseAuthRepository implements IAuthRepository {
  SupabaseAuthRepository(this._client);

  final sb.SupabaseClient _client;

  sb.GoTrueClient get _auth => _client.auth;

  @override
  Stream<AppUser?> get authStateChanges async* {
    // Emite el estado actual de forma sincrónica antes de suscribirse al stream.
    // En web, Supabase puede tardar varios segundos en emitir el INITIAL_SESSION;
    // esto garantiza que el router nunca quede atascado en el splash.
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        yield await _fetchProfile(currentUser.id);
      } catch (_) {
        yield null;
      }
    } else {
      yield null;
    }

    // A partir de aquí escucha cambios en tiempo real (login / logout)
    await for (final event in _auth.onAuthStateChange) {
      if (event.session == null) {
        yield null;
      } else {
        try {
          yield await _fetchProfile(event.session!.user.id);
        } catch (_) {
          yield null;
        }
      }
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw const AuthException('No se pudo iniciar sesión.');
      return _fetchProfile(user.id);
    } on sb.AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      final user = response.user;
      if (user == null) throw const AuthException('No se pudo crear la cuenta.');
      return _fetchProfile(user.id);
    } on sb.AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on sb.AuthException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  @override
  Future<AppUser> updateProfile({String? fullName, String? avatarUrl}) async {
    final userId = _auth.currentUser?.id;
    if (userId == null) throw const AuthException('No hay sesión activa.');

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _client
        .from(AppConstants.tableProfiles)
        .update(updates)
        .eq('id', userId);

    return _fetchProfile(userId);
  }

  @override
  Future<String> redeemInvitationCode(String code) async {
    try {
      final result = await _client.rpc(
        'redeem_invitation_code',
        params: {'p_code': code},
      );
      final json = Map<String, dynamic>.from(result as Map);
      if (json['success'] != true) {
        throw InvalidInvitationCodeException(
          json['error'] as String? ?? 'Código inválido.',
        );
      }
      return json['student_id'] as String;
    } on InvalidInvitationCodeException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al canjear código: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<AppUser> _fetchProfile(String userId) async {
    final data = await _client
        .from(AppConstants.tableProfiles)
        .select()
        .eq('id', userId)
        .single();
    return AppUserModel.fromJson(data).toEntity();
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.contains('Email already registered') ||
        message.contains('already been registered')) {
      return 'Este correo ya está registrado.';
    }
    if (message.contains('Password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return message;
  }
}
