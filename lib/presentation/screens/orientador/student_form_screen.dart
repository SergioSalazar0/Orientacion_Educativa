import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../viewmodels/student_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../../domain/entities/student.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  const StudentFormScreen({super.key, this.studentId});

  final String? studentId;

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _formKey = GlobalKey<FormState>();

  // Campos del formulario
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _semesterCtrl = TextEditingController();
  final _groupCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bloodTypeCtrl = TextEditingController();
  final _insuranceCtrl = TextEditingController();
  final _nssCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _medicalNotesCtrl = TextEditingController();

  bool _showImportMode = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    if (widget.studentId != null) _loadStudent();
  }

  Future<void> _loadStudent() async {
    final student =
        await ref.read(studentDetailProvider(widget.studentId!).future);
    _codeCtrl.text = student.studentCode;
    _nameCtrl.text = student.fullName;
    _semesterCtrl.text = student.semester;
    _groupCtrl.text = student.group;
    _specialtyCtrl.text = student.specialty;
    _addressCtrl.text = student.address ?? '';
    _bloodTypeCtrl.text = student.bloodType ?? '';
    _insuranceCtrl.text = student.insurance ?? '';
    _nssCtrl.text = student.nss ?? '';
    _allergiesCtrl.text = student.allergies ?? '';
    _medicalNotesCtrl.text = student.medicalNotes ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (final c in [
      _codeCtrl, _nameCtrl, _semesterCtrl, _groupCtrl, _specialtyCtrl,
      _addressCtrl, _bloodTypeCtrl, _insuranceCtrl, _nssCtrl,
      _allergiesCtrl, _medicalNotesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final student = Student(
      id: widget.studentId ?? '',
      studentCode: _codeCtrl.text.trim(),
      fullName: _nameCtrl.text.trim(),
      semester: _semesterCtrl.text.trim(),
      group: _groupCtrl.text.trim().toUpperCase(),
      specialty: _specialtyCtrl.text.trim(),
      status: StudentStatus.activo,
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      bloodType: _bloodTypeCtrl.text.trim().isEmpty ? null : _bloodTypeCtrl.text.trim(),
      insurance: _insuranceCtrl.text.trim().isEmpty ? null : _insuranceCtrl.text.trim(),
      nss: _nssCtrl.text.trim().isEmpty ? null : _nssCtrl.text.trim(),
      allergies: _allergiesCtrl.text.trim().isEmpty ? null : _allergiesCtrl.text.trim(),
      medicalNotes: _medicalNotesCtrl.text.trim().isEmpty ? null : _medicalNotesCtrl.text.trim(),
    );
    final ok = await ref
        .read(studentFormViewModelProvider.notifier)
        .save(student);
    if (ok && mounted) context.pop();
  }

  Future<void> _pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );
    if (result == null || result.files.single.bytes == null) return;
    final file = result.files.single;
    final ok = await ref
        .read(studentFormViewModelProvider.notifier)
        .importFromFile(
          file.bytes!,
          file.extension ?? 'csv',
        );
    if (ok && mounted) {
      final results = ref.read(studentFormViewModelProvider).importResults ?? [];
      final errors = results.where((r) => !r.isSuccess).length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${results.length - errors} alumnos importados. $errors errores.'),
        ),
      );
      if (errors == 0) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentFormViewModelProvider);
    final isEdit = widget.studentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Alumno' : 'Registrar Alumno'),
        bottom: !isEdit
            ? TabBar(
                controller: _tabCtrl,
                tabs: const [
                  Tab(icon: Icon(Symbols.person_add), text: 'Manual'),
                  Tab(icon: Icon(Symbols.upload_file), text: 'Importar'),
                ],
                onTap: (i) => setState(() => _showImportMode = i == 1),
              )
            : null,
      ),
      body: _showImportMode ? _ImportTab(onImport: _pickAndImport, state: state) : _buildForm(state),
    );
  }

  Widget _buildForm(dynamic state) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Datos académicos
          _SectionHeader('Datos Académicos'),
          AppTextField(
            label: 'Matrícula *',
            controller: _codeCtrl,
            hint: 'Ej. 20240001',
            prefixIcon: Symbols.badge,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Requerido' : null,
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Nombre Completo *',
            controller: _nameCtrl,
            hint: 'Apellidos Nombre',
            prefixIcon: Symbols.person,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Requerido' : null,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Semestre *',
                  controller: _semesterCtrl,
                  hint: '1-6',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ).animate().fadeIn(delay: 150.ms),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Grupo *',
                  controller: _groupCtrl,
                  hint: 'A, B, C...',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ).animate().fadeIn(delay: 150.ms),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Especialidad *',
            controller: _specialtyCtrl,
            hint: 'Programación, Contabilidad...',
            prefixIcon: Symbols.school,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Requerido' : null,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 20),
          _SectionHeader('Datos de Salud'),
          AppTextField(
            label: 'Tipo de Sangre',
            controller: _bloodTypeCtrl,
            hint: 'O+, A+, B-...',
            prefixIcon: Symbols.bloodtype,
          ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Seguro',
            controller: _insuranceCtrl,
            hint: 'IMSS, ISSSTE...',
            prefixIcon: Symbols.health_and_safety,
          ).animate().fadeIn(delay: 270.ms),
          const SizedBox(height: 12),
          AppTextField(
            label: 'NSS',
            controller: _nssCtrl,
            hint: 'Número de Seguro Social',
            prefixIcon: Symbols.badge,
          ).animate().fadeIn(delay: 290.ms),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Alergias',
            controller: _allergiesCtrl,
            hint: 'Penicilina, nueces...',
            maxLines: 2,
          ).animate().fadeIn(delay: 310.ms),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Notas médicas',
            controller: _medicalNotesCtrl,
            hint: 'Diagnósticos, medicamentos...',
            maxLines: 3,
          ).animate().fadeIn(delay: 330.ms),

          const SizedBox(height: 20),
          _SectionHeader('Domicilio'),
          AppTextField(
            label: 'Domicilio',
            controller: _addressCtrl,
            hint: 'Calle, colonia, ciudad...',
            prefixIcon: Symbols.home,
            maxLines: 2,
          ).animate().fadeIn(delay: 350.ms),

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
            label: widget.studentId != null ? 'Guardar cambios' : 'Registrar alumno',
            icon: Symbols.save,
            isLoading: state.isLoading,
            onPressed: _submit,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
      ),
    );
  }
}

class _ImportTab extends StatelessWidget {
  const _ImportTab({required this.onImport, required this.state});

  final VoidCallback onImport;
  final dynamic state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.upload_file,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 24),
          Text(
            'Importación masiva',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            'El archivo debe tener las columnas:\nmatricula, nombre, semestre, grupo, especialidad',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          AppButton(
            label: 'Seleccionar archivo .CSV / .XLSX',
            icon: Symbols.folder_open,
            isLoading: state.isLoading,
            onPressed: onImport,
          ).animate().fadeIn(delay: 300.ms),
          if (state.importResults != null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Resultados:',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            ...state.importResults!.map((r) => ListTile(
                  dense: true,
                  leading: Icon(
                    r.isSuccess ? Icons.check_circle : Icons.error,
                    color: r.isSuccess
                        ? const Color(0xFF16A34A)
                        : Theme.of(context).colorScheme.error,
                    size: 18,
                  ),
                  title: Text(
                    r.isSuccess
                        ? r.student!.fullName
                        : 'Fila ${r.rowIndex}: ${r.error}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
