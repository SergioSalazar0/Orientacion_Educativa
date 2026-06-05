import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/report.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/repository_providers.dart';

class ReportEditScreen extends ConsumerStatefulWidget {
  const ReportEditScreen({super.key, required this.reportId, required this.studentId});

  final String reportId;
  final String studentId;

  @override
  ConsumerState<ReportEditScreen> createState() =>
      _ReportEditScreenState();
}

class _ReportEditScreenState extends ConsumerState<ReportEditScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ReportCategory? _category;
  List<int>? _imageBytes;
  String? _imageName;
  String? _currentImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      final repo = ref.read(reportRepositoryProvider);
      final report = await repo.getReportById(widget.reportId);
      setState(() {
        _titleCtrl.text = report.title;
        _descCtrl.text = report.description;
        _category = report.category;
        _currentImageUrl = report.imageUrl;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e')),
        );
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final ext = image.path.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        setState(() {
          _imageBytes = bytes;
          _imageName = image.name;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }

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
      id: widget.reportId,
      studentId: widget.studentId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category!,
      imageUrl: _currentImageUrl,
      createdBy: currentUser.id,
    );

    final ok = await ref
        .read(reportViewModelProvider.notifier)
        .update(report);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte actualizado')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportViewModelProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Reporte')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Reporte')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Título *',
              controller: _titleCtrl,
              hint: 'Título del reporte...',
              prefixIcon: Symbols.title,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ).animate().fadeIn(delay: 50.ms),
            const SizedBox(height: 12),
            // Categoría
            DropdownButtonFormField<ReportCategory>(
              initialValue: _category,
              items: ReportCategory.values
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.label),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _category = val),
              decoration: InputDecoration(
                labelText: 'Categoría *',
                prefixIcon: const Icon(Symbols.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) => v == null ? 'Selecciona una categoría' : null,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Descripción *',
              controller: _descCtrl,
              hint: 'Detalles del reporte...',
              maxLines: 4,
              prefixIcon: Symbols.description,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Symbols.image),
              label: Text(_imageName ?? 'Cambiar imagen'),
            ).animate().fadeIn(delay: 200.ms),
            if (_imageName != null) ...[
              const SizedBox(height: 6),
              Text(
                '✓ $_imageName (nueva)',
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else if (_currentImageUrl != null) ...[
              const SizedBox(height: 6),
              Text(
                '✓ Imagen existente',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
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
              label: 'Actualizar Reporte',
              icon: Symbols.save,
              isLoading: state.isLoading,
              onPressed: _submit,
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
