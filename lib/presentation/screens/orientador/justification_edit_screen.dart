import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/entities/justification.dart';
import '../../viewmodels/justification_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../providers/repository_providers.dart';

class JustificationEditScreen extends ConsumerStatefulWidget {
  const JustificationEditScreen({super.key, required this.justificationId, required this.studentId});

  final String justificationId;
  final String studentId;

  @override
  ConsumerState<JustificationEditScreen> createState() =>
      _JustificationEditScreenState();
}

class _JustificationEditScreenState
    extends ConsumerState<JustificationEditScreen> {
  final _reasonCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  List<int>? _fileBytes;
  String? _fileExt;
  String? _fileName;
  String? _currentFileUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _loadJustification();
  }

  Future<void> _loadJustification() async {
    try {
      final repo = ref.read(justificationRepositoryProvider);
      final justification = await repo.getJustificationById(widget.justificationId);
      setState(() {
        _reasonCtrl.text = justification.reason;
        _descCtrl.text = justification.description ?? '';
        _date = justification.date;
        _currentFileUrl = justification.fileUrl;
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
    _reasonCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result?.files.single.bytes != null) {
      setState(() {
        _fileBytes = result!.files.single.bytes!;
        _fileExt = result.files.single.extension;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
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

    final justification = Justification(
      id: widget.justificationId,
      studentId: widget.studentId,
      reason: _reasonCtrl.text.trim(),
      date: _date,
      status: JustificationStatus.pendiente,
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      fileUrl: _currentFileUrl,
      createdBy: currentUser.id,
    );

    final ok = await ref
        .read(justificationViewModelProvider.notifier)
        .update(justification, fileBytes: _fileBytes, fileExt: _fileExt);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Justificante actualizado')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(justificationViewModelProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Justificante')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Justificante')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Motivo *',
              controller: _reasonCtrl,
              hint: 'Cita médica, asunto familiar...',
              prefixIcon: Symbols.description,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ).animate().fadeIn(delay: 50.ms),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Descripción (opcional)',
              controller: _descCtrl,
              hint: 'Detalles adicionales...',
              maxLines: 3,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),
            // Fecha
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de ausencia',
                  prefixIcon: Icon(Symbols.calendar_today),
                ),
                child: Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Symbols.attach_file),
              label: Text(_fileName ?? 'Cambiar comprobante (PDF/imagen)'),
            ).animate().fadeIn(delay: 200.ms),
            if (_fileName != null) ...[
              const SizedBox(height: 6),
              Text(
                '✓ $_fileName (nuevo)',
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else if (_currentFileUrl != null) ...[
              const SizedBox(height: 6),
              Text(
                '✓ Comprobante existente',
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
              label: 'Actualizar Justificante',
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
