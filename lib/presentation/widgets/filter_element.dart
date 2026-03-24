import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart';

class GraphColumnSelector extends StatelessWidget {
  const GraphColumnSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FilterElement>();
    
    // Tus opciones basadas en las columnas de la BD
    final List<String> columns = [
      'CIP', 'DesaireadorA', 'DesaireadorB', 'DesaireadorC', 
      'Fuerza', 'Lavadoras', 'LineasPET', 'Multimix', 
      'Potable', 'Quasy', 'Servicios', 'Contisiolv'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.selectedColumn,
          dropdownColor: const Color(0xFF1E1E1E),
          icon: const Icon(Icons.analytics, color: Colors.blue),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: (String? newValue) {
            if (newValue != null) {
              provider.updateColumn(newValue);
            }
          },
          items: columns.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}