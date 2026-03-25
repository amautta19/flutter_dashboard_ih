import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart';

class GraphColumnSelector extends StatelessWidget {
  const GraphColumnSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FilterElement>();
    
    final List<String> columns = [
      'CIP', 'DesaireadorA', 'DesaireadorB', 'DesaireadorC', 
      'Fuerza', 'Lavadoras', 'LineasPET', 'Multimix', 
      'Potable', 'Quasy', 'Servicios', 'Contisiolv'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: ColorDefaults.darkPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorDefaults.darkPrimary),
            boxShadow: [
              BoxShadow(
                color: ColorDefaults.darkPrimary,
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Wrap( // Wrap para que si hay muchas opciones no se rompa la pantalla
            spacing: 8,
            runSpacing: 8,
            children: columns.map((String value) {
              final isSelected = provider.selectedColumn == value;
              
              return ChoiceChip(
                label: GlobalText(value, 
                  color: isSelected ? ColorDefaults.whitePrimary : ColorDefaults.darkPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) provider.updateColumn(value);
                },
                // --- ESTILO BASADO EN TU PALETA ---
                // labelStyle: TextStyle(
                //   color: isSelected ? Colors.white : ColorDefaults.darkPrimary,
                //   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                //   fontSize: 14,
                // ),
                selectedColor: ColorDefaults.primaryBlue, // Tu azul principal
                backgroundColor: ColorDefaults.whitePrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? ColorDefaults.primaryBlue : ColorDefaults.darkPrimary.withOpacity(0.3),
                  ),
                ),
                elevation: isSelected ? 4 : 0,
                pressElevation: 2,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}