import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/router/app_router.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/student_card.dart';

class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(studentFilterProvider);
    final studentsAsync = ref.watch(filteredStudentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Búsqueda de Alumnos')),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Nombre del alumno...',
                prefixIcon: const Icon(Symbols.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref
                              .read(studentFilterProvider.notifier)
                              .state = const StudentFilter();
                        },
                      )
                    : null,
              ),
              onChanged: (v) => ref.read(studentFilterProvider.notifier).state =
                  StudentFilter(
                search: v,
                semester: filter.semester,
                group: filter.group,
                specialty: filter.specialty,
              ),
            ),
          ).animate().fadeIn(),

          // Filtros
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    hint: 'Semestre',
                    value: filter.semester,
                    items: const ['1', '2', '3', '4', '5', '6'],
                    onChanged: (v) =>
                        ref.read(studentFilterProvider.notifier).state =
                            StudentFilter(
                      search: filter.search,
                      semester: v,
                      group: filter.group,
                      specialty: filter.specialty,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilterDropdown(
                    hint: 'Grupo',
                    value: filter.group,
                    items: const ['A', 'B', 'C', 'D'],
                    onChanged: (v) =>
                        ref.read(studentFilterProvider.notifier).state =
                            StudentFilter(
                      search: filter.search,
                      semester: filter.semester,
                      group: v,
                      specialty: filter.specialty,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          // Lista
          Expanded(
            child: studentsAsync.when(
              loading: () => const ShimmerLoader(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (students) => students.isEmpty
                  ? EmptyState(
                      icon: Symbols.group,
                      title: 'No se encontraron alumnos',
                      subtitle: 'Intenta con otros filtros o registra un alumno',
                      actionLabel: 'Registrar alumno',
                      onAction: () => context.push(AppRoutes.studentNew),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => StudentCard(
                        student: students[i],
                        index: i,
                        onTap: () => context.push(
                          AppRoutes.studentDetail.replaceFirst(
                              ':id', students[i].id),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.studentNew),
        icon: const Icon(Symbols.person_add),
        label: const Text('Registrar'),
      ).animate().scale(delay: 300.ms),
      bottomNavigationBar: const OrientadorBottomNav(currentIndex: 2),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
  });

  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos')),
        ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ],
      onChanged: onChanged,
    );
  }
}
