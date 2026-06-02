import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centraliza la lectura de variables de entorno del archivo .env.
/// Lanza [StateError] si alguna variable requerida no está definida.
class Env {
  Env._();

  static String get supabaseUrl => _require('SUPABASE_URL');
  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Variable de entorno requerida no encontrada: $key');
    }
    return value;
  }
}
