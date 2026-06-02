import 'package:flutter/material.dart';

import '../../domain/entities/justification.dart';
import '../../domain/entities/appointment.dart';

/// Badge de estado con colores semánticos según el tipo de entidad.
class StatusBadge extends StatelessWidget {
  const StatusBadge.justification(JustificationStatus status, {super.key})
      : _label = status == JustificationStatus.aprobado
            ? 'Aprobado'
            : status == JustificationStatus.rechazado
                ? 'Rechazado'
                : 'Pendiente',
        _color = status == JustificationStatus.aprobado
            ? const Color(0xFF16A34A)
            : status == JustificationStatus.rechazado
                ? const Color(0xFFDC2626)
                : const Color(0xFFD97706),
        _bg = status == JustificationStatus.aprobado
            ? const Color(0xFFDCFCE7)
            : status == JustificationStatus.rechazado
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFFEF3C7);

  const StatusBadge.appointment(AppointmentStatus status, {super.key})
      : _label = status == AppointmentStatus.confirmada
            ? 'Confirmada'
            : status == AppointmentStatus.cancelada
                ? 'Cancelada'
                : 'Programada',
        _color = status == AppointmentStatus.confirmada
            ? const Color(0xFF16A34A)
            : status == AppointmentStatus.cancelada
                ? const Color(0xFFDC2626)
                : const Color(0xFF2563EB),
        _bg = status == AppointmentStatus.confirmada
            ? const Color(0xFFDCFCE7)
            : status == AppointmentStatus.cancelada
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFDBEAFE);

  final String _label;
  final Color _color;
  final Color _bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
