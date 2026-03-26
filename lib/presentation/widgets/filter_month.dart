import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import '../../providers/filter_month_provider.dart';

class FilterMonthWidget extends StatelessWidget {
  const FilterMonthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final monthProvider = context.watch<FilterMonthProvider>();

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        // Padding para que no pegue a los bordes del contenedor blanco
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: ColorDefaults.whitePrimary, // Fondo blanco sólido
          borderRadius: BorderRadius.circular(12), // Bordes redondeados como la imagen
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- TEXTO DE DISEÑO AL COSTADO ---
              const Text(
                "Filtrar Mes:",
                style: TextStyle(
                  color: Color(0xFF5F6368), // Gris oscuro de la imagen
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
      
              // --- LÍNEA VERTICAL DIVISORIA ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: VerticalDivider(
                  color: Colors.black12,
                  thickness: 1,
                ),
              ),
      
              // --- DROPDOWN DE MESES ---
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: monthProvider.selectedMonth,
                  dropdownColor: ColorDefaults.whitePrimary,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
                  style: const TextStyle(
                    color: Color(0xFF3C4043), // Texto oscuro profesional
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      monthProvider.updateMonth(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Enero")),
                    DropdownMenuItem(value: 2, child: Text("Febrero")),
                    DropdownMenuItem(value: 3, child: Text("Marzo")),
                    DropdownMenuItem(value: 4, child: Text("Abril")),
                    DropdownMenuItem(value: 5, child: Text("Mayo")),
                    DropdownMenuItem(value: 6, child: Text("Junio")),
                    DropdownMenuItem(value: 7, child: Text("Julio")),
                    DropdownMenuItem(value: 8, child: Text("Agosto")),
                    DropdownMenuItem(value: 9, child: Text("Septiembre")),
                    DropdownMenuItem(value: 10, child: Text("Octubre")),
                    DropdownMenuItem(value: 11, child: Text("Noviembre")),
                    DropdownMenuItem(value: 12, child: Text("Diciembre")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}