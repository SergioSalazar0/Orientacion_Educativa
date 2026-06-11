import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../providers/repository_providers.dart';
import 'student_viewmodel.dart';

/// Estado del ViewModel de autenticación.
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  final bool isLoading;
  final String? errorMessage;
  final AppUser? user;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    AppUser? user,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        user: user ?? this.user,
      );
}

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = AuthState(user: user);
      return true;
    } on AppException catch (e) {
      state = AuthState(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            fullName: fullName,
          );
      state = AuthState(user: user);
      return true;
    } on AppException catch (e) {
      state = AuthState(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      state = const AuthState();
      return true;
    } on AppException catch (e) {
      state = AuthState(errorMessage: e.message);
      return false;
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState();
  }

  Future<bool> redeemInvitationCode(String code) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).redeemInvitationCode(code);
      // Invalidar el stream de estudiantes para que se refresque
      ref.invalidate(studentsStreamProvider);
      state = const AuthState();
      return true;
    } on AppException catch (e) {
      state = AuthState(errorMessage: e.message);
      return false;
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);
  
  void clearState() => state = const AuthState();
}

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);
