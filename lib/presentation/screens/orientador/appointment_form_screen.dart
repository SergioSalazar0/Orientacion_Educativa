import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../domain/entities/appointment.dart';
import '../../viewmodels/appointment_viewmodel.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class AppointmentFormScreen extends ConsumerStatefulWidget {
  const AppointmentFormScreen({super.key, this.preselectedStudentId});

  final String? preselectedStudentId;

  @override
  ConsumerState<AppointmentFormScreen> createState() =>
      _AppointmentFormScreenState();
}

class _AppointmentFormScreenState
    extends ConsumerState<AppointmentFormScreen> {
  final _guardianCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedStudentId;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  AppointmentReason _reason = AppointmentReason.seguimiento;

  static const _timeSlots = [
    '08:00', '09:30', '11:00', '12:30', '14:00', '15:30',
  ];
  String _selectedSlot = '09:30';

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.preselectedStudentId;
  }

  @override
  void dispose() {
    _guardianCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un alumno')),
      );
      return;
    }
    final appointment = Appointment(
      id: '',
      studentId: _selectedStudentId!,
      guardianName: _guardianCtrl.text.trim(),
      date: _date,
      time: _selectedSlot,
      reason: _reason,
      status: AppointmentStatus.programada,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    final ok = await ref
        .read(appointmentViewModelProvider.notifier)
        .create(appointment);
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentViewModelProvider);
    final studentsAsync = ref.watch(filteredStudentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Nueva Cita')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seleccionar alumno
            Text(
              'SELECCIONAR ALUMNO',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ).animate().fadeIn(),
            const SizedBox(height: 8),
            studentsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (students) => DropdownButtonFormField<String>(
                initialValue: _selectedStudentId,
                hint: const Text('Buscar alumno...'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Symbols.person_search),
                ),
                items: students
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text('${s.fullName} — ${s.semesterGroup}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStudentId = v),
              ),
            ).animate().fadeIn(delay: 80.ms),

            const SizedBox(height: 16),
            AppTextField(
              label: 'Nombre del Padre o Tutor *',
              controller: _guardianCtrl,
              hint: 'Nombre completo del acudiente...',
              prefixIcon: Symbols.person,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 16),

            // Fecha
            Text(
              'FECHA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Symbols.calendar_today),
              label: Text(
                  '${_date.day}/${_date.month}/${_date.year}'),
            ).animate().fadeIn(delay: 220.ms),

            const SizedBox(height: 16),

            // Horarios
            Text(
              'HORA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ).animate().fadeIn(delay: 240.ms),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((slot) {
                final selected = _selectedSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedSlot = slot),
                  selectedColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                );
              }).toList(),
            ).animate().fadeIn(delay: 260.ms),

            const SizedBox(height: 16),

            // Motivo
            Text(
              'MOTIVO',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ).animate().fadeIn(delay: 280.ms),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppointmentReason.values.map((r) {
                final selected = _reason == r;
                return ChoiceChip(
                  label: Text(r.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _reason = r),
                  selectedColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                );
              }).toList(),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),
            AppTextField(
              label: 'Notas adicionales',
              controller: _notesCtrl,
              hint: 'Escribe detalles importantes para la sesión...',
              maxLines: 4,
            ).animate().fadeIn(delay: 320.ms),

            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 13),
              ).animate().shake(),
            ],

            const SizedBox(height: 28),
            AppButton(
              label: 'Confirmar Cita',
              icon: Symbols.event_available,
              isLoading: state.isLoading,
              onPressed: _submit,
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
