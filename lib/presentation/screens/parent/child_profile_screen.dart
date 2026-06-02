import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/avatar_image.dart';
import '../../widgets/shimmer_loader.dart';

class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil del Alumno'), centerTitle: true),
      body: studentsAsync.when(
        loading: () => const ShimmerLoader(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('Sin alumnos vinculados'));
          }
          final student = students.first;
          return ListView(
            children: [
              // Foto y nombre
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AvatarImage(
                          url: student.photoUrl,
                          name: student.fullName,
                          radius: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          student.fullName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _Chip(student.semesterGroup),
                            _Chip('ID: ${student.studentCode}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(),

              // Información de salud
              _Section(
                title: 'Información de Salud',
                children: [
                  _Row('Tipo de sangre', student.bloodType ?? '—'),
                  _Row('Seguro', student.insurance ?? '—'),
                  _Row('NSS', student.nss ?? '—'),
                  _Row('Alergias', student.allergies ?? '—'),
                  _Row('Notas médicas', student.medicalNotes ?? '—'),
                ],
              ).animate().fadeIn(delay: 100.ms),

              // Domicilio
              _Section(
                title: 'Domicilio',
                children: [
                  _Row('Dirección', student.address ?? '—'),
                ],
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
      bottomNavigationBar: const ParentBottomNav(currentIndex: 3),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
