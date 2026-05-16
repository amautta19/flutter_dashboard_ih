import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';

class CardWur extends StatelessWidget {
  final List<dynamic> allData;
  final double umbral;

  const CardWur({
    super.key,
    required this.allData,
    required this.umbral,
  });

  // ── Obtener el WUR más reciente ──────────────────────────────
  double get _valorActual {
    if (allData.isEmpty) return 0.0;
    final ultimo = allData.last;
    return (ultimo['wur_anual'] ?? 0).toDouble();
  }

  // ── Sumar total litros bebida ────────────────────────────────
  double get _litrosBebida {
    if (allData.isEmpty) return 0.0;
    return allData.fold(0.0, (sum, item) => sum + (item['total_m3_bebida_anual'] ?? 0).toDouble());
  }

  // ── Sumar total litros pozos ─────────────────────────────────
  double get _litrosPozos {
    if (allData.isEmpty) return 0.0;
    return allData.fold(0.0, (sum, item) => sum + (item['total_pozos_anual'] ?? 0).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final double valorActual = _valorActual;
    final double litrosBebida = _litrosBebida;
    final double litrosPozos = _litrosPozos;

    final bool esEficiente = valorActual <= umbral;
    final Color colorEstado = esEficiente ? const Color(0xFF00FFC2) : const Color(0xFFFF5252);

    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorEstado.withOpacity(0.3), width: 2),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorDefaults.darkCyan,
          ),
          const SizedBox(height: 10),

          // ── Mini stats ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Bebida', litrosBebida, Icons.local_drink_rounded),
              _buildMiniStat('Pozos', litrosPozos, Icons.waves_rounded),
            ],
          ),

          const SizedBox(height: 10),

          // ── Valor WUR ────────────────────────────────────────
          GlobalText(
            valorActual.toStringAsFixed(2),
            fontSize: 62,
            fontWeight: FontWeight.w900,
            color: colorEstado,
          ),
          const SizedBox(height: 12),

          // ── Indicador umbral ─────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 12, color: colorEstado.withOpacity(0.7)),
                const SizedBox(width: 6),
                GlobalText(
                  'UMBRAL: $umbral',
                  fontSize: 10,
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

  Widget _buildMiniStat(String label, double value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white38),
            const SizedBox(width: 4),
            GlobalText(label, fontSize: 14, color: Colors.white38, fontWeight: FontWeight.bold),
          ],
        ),
        GlobalText(
          '${value.toStringAsFixed(0)} m3',
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}