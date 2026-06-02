import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/router/app_router.dart';

/// Barra de navegación inferior para el Orientador.
class OrientadorBottomNav extends StatelessWidget {
  const OrientadorBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => _navigate(context, i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Symbols.home),
          selectedIcon: Icon(Symbols.home, fill: 1),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Symbols.calendar_month),
          selectedIcon: Icon(Symbols.calendar_month, fill: 1),
          label: 'Citas',
        ),
        NavigationDestination(
          icon: Icon(Symbols.group),
          selectedIcon: Icon(Symbols.group, fill: 1),
          label: 'Alumnos',
        ),
        NavigationDestination(
          icon: Icon(Symbols.description),
          selectedIcon: Icon(Symbols.description, fill: 1),
          label: 'Reportes',
        ),
      ],
    );
  }

  void _navigate(BuildContext context, int index) {
    final routes = [
      AppRoutes.orientadorDashboard,
      AppRoutes.appointmentsList,
      AppRoutes.studentsList,
      AppRoutes.reportsHistory,
    ];
    context.go(routes[index]);
  }
}

/// Barra de navegación inferior para el Padre de familia.
class ParentBottomNav extends StatelessWidget {
  const ParentBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => _navigate(context, i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Symbols.home),
          selectedIcon: Icon(Symbols.home, fill: 1),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Symbols.analytics),
          selectedIcon: Icon(Symbols.analytics, fill: 1),
          label: 'Reportes',
        ),
        NavigationDestination(
          icon: Icon(Symbols.assignment_turned_in),
          selectedIcon: Icon(Symbols.assignment_turned_in, fill: 1),
          label: 'Justificantes',
        ),
        NavigationDestination(
          icon: Icon(Symbols.person),
          selectedIcon: Icon(Symbols.person, fill: 1),
          label: 'Perfil',
        ),
      ],
    );
  }

  void _navigate(BuildContext context, int index) {
    final routes = [
      AppRoutes.parentHome,
      AppRoutes.parentReports,
      AppRoutes.parentJustifications,
      AppRoutes.childProfile,
    ];
    context.go(routes[index]);
  }
}
