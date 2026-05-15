import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';

class CardWur extends StatelessWidget {
  final double valorActual;
  final double umbral;
  final double litrosBebida; // Nuevo
  final double litrosPozos;  // Nuevo

  const CardWur({
    super.key,
    required this.valorActual,
    required this.umbral,
    required this.litrosBebida,
    required this.litrosPozos,
  });

  @override
  Widget build(BuildContext context) {
    final bool esEficiente = valorActual <= umbral;
    final Color colorEstado = esEficiente ? const Color(0xFF00FFC2) : const Color(0xFFFF5252);

    return Container(
      width: 260, // Aumentamos un pelo el ancho para que respiren los datos nuevos
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
            color: ColorDefaults.primaryBlue,
          ),
          const SizedBox(height: 10),
          
          // --- SECCIÓN NUEVA: LITROS BEBIDA Y POZOS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Bebida', litrosBebida, Icons.local_drink_rounded),
              _buildMiniStat('Pozos', litrosPozos, Icons.waves_rounded),
            ],
          ),
          // --------------------------------------------

          const SizedBox(height: 10),
          GlobalText(
            valorActual.toStringAsFixed(2),
            fontSize: 62,
            fontWeight: FontWeight.w900,
            color: colorEstado,
          ),
          const SizedBox(height: 12),
          
          // Indicador de umbral
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

  // Widget auxiliar para los textos pequeños de litros
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
          '${(value).toStringAsFixed(0)} m3', // Lo mostramos en 'k' para que no ocupe espacio
          fontSize: 14,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}