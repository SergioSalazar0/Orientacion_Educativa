import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/report.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ReportFormScreen extends ConsumerStatefulWidget {
  const ReportFormScreen({super.key, required this.studentId});

  final String studentId;

  @override
  ConsumerState<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends ConsumerState<ReportFormScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ReportCategory _category = ReportCategory.conducta;
  List<int>? _imageBytes;
  String? _imageExt;
  String? _imageName;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result?.files.single.bytes != null) {
      setState(() {
        _imageBytes = result!.files.single.bytes!;
        _imageExt = result.files.single.extension;
        _imageName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
      }
      return;
    }

    final report = Report(
      id: '',
      studentId: widget.studentId,
      category: _category,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      createdBy: currentUser.id,
    );
    final ok = await ref.read(reportViewModelProvider.notifier).save(
          report,
          imageBytes: _imageBytes,
          imageExt: _imageExt,
        );
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Reporte')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Categoría
            Text(
              'CATEGORÍA',
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
            Wrap(
              spacing: 8,
              children: ReportCategory.values.map((cat) {
                final selected = _category == cat;
                return ChoiceChip(
                  label: Text(cat.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = cat),
                  selectedColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                );
              }).toList(),
            ).animate().fadeIn(delay: 80.ms),

            const SizedBox(height: 16),
            AppTextField(
              label: 'Título *',
              controller: _titleCtrl,
              hint: 'Ej. Incidente en clase',
              prefixIcon: Symbols.title,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 12),
            AppTextField(
              label: 'Descripción *',
              controller: _descCtrl,
              hint: 'Describe el reporte detalladamente...',
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),
            // Imagen opcional
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Symbols.add_photo_alternate),
              label: Text(
                _imageName ?? 'Agregar imagen (opcional)',
              ),
            ).animate().fadeIn(delay: 250.ms),

            if (_imageName != null) ...[
              const SizedBox(height: 8),
              Text(
                '✓ $_imageName',
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

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
              label: 'Guardar Reporte',
              icon: Symbols.save,
              isLoading: state.isLoading,
              onPressed: _submit,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
