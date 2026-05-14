import 'package:flutter/material.dart';

class CardWur extends StatelessWidget {
  const CardWur({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Ajusta según el espacio en tu layout
      height: 150,
      decoration: BoxDecoration(
        // color: const Color(0xFF1E293B),
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.blueAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Un pequeño adorno visual de fondo (opcional)
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.water_drop_outlined,
              size: 80,
              color: Colors.blueAccent.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'WUR ACUMULADO',
                  style: TextStyle(
                    color: Colors.blueAccent[100],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '1.58', // Valor de ejemplo
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'm³/hl', // Unidad típica de WUR
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                // Indicador de tendencia simple
                Row(
                  children: [
                    const Icon(Icons.trending_down, color: Colors.greenAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '-2.4% vs ayer',
                      style: TextStyle(
                        color: Colors.greenAccent[400],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}