import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';

class CardWur extends StatelessWidget {
  final double valorActual;
  final double umbral;

  const CardWur({
    super.key,
    required this.valorActual,
    required this.umbral,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos si el proceso es eficiente según tu umbral de planta
    final bool esEficiente = valorActual <= umbral;
    // Verde Cian para eficiencia, Rojo suave para ineficiencia
    final Color colorEstado = esEficiente ? const Color(0xFF00FFC2) : const Color(0xFFFF5252);

    return Container(
      width: 240,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        // Gradiente Azul un poco más claro y profesional
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B), // Slate 800: Más claro que el anterior
            const Color(0xFF0F172A), // Slate 900: Mantiene la profundidad
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorEstado.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlobalText(
            'WUR 2026',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          // El KPI principal
          GlobalText(
            valorActual.toStringAsFixed(2),
            fontSize: 68, // Un poco más grande para llenar el espacio
            fontWeight: FontWeight.w900,
            color: colorEstado,
          ),
          const SizedBox(height: 16),
          // Indicador de umbral minimalista
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 14, color: colorEstado.withOpacity(0.7)),
                const SizedBox(width: 6),
                GlobalText(
                  'UMBRAL: $umbral',
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}