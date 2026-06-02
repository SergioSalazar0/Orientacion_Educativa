import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga variables de entorno desde el archivo .env (no se sube al repo)
  await dotenv.load(fileName: '.env');

  // Inicializa Supabase con las credenciales del .env
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Inicializa localización en español para intl (fechas)
  await initializeDateFormatting('es_MX');

  runApp(
    // ProviderScope es el contenedor raíz de Riverpod
    const ProviderScope(child: OrientacionApp()),
  );
}

class OrientacionApp extends ConsumerWidget {
  const OrientacionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Orientación Educativa CBTIS',
      debugShowCheckedModeBanner: false,

      // Temas light y dark basados en los mockups de UI_design
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Navegación declarativa con GoRouter
      routerConfig: router,
    );
  }
}
