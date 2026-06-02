/// Excepciones tipadas de la aplicación.
/// Permite manejar errores de dominio sin depender de excepciones de Supabase.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Error de autenticación: credenciales incorrectas, sesión expirada, etc.
class AuthException extends AppException {
  const AuthException(super.message);
}

/// El recurso solicitado no existe en la base de datos.
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Error al procesar un archivo CSV o XLSX para importación masiva.
class FileImportException extends AppException {
  const FileImportException(super.message, {this.row});

  /// Fila del archivo que causó el error (base 1, null = error general).
  final int? row;
}

/// El código de invitación es inválido, ya fue usado o expiró.
class InvalidInvitationCodeException extends AppException {
  const InvalidInvitationCodeException(super.message);
}

/// Error de permisos: el usuario no tiene acceso al recurso.
class PermissionException extends AppException {
  const PermissionException(super.message);
}

/// Error de red o de servidor desconocido.
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Error de validación de formulario en el dominio.
class ValidationException extends AppException {
  const ValidationException(super.message);
}
