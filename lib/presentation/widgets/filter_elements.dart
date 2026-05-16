import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart';

class FilterElementWidget extends StatefulWidget {
  final List<String> columns;
  const FilterElementWidget({super.key, required this.columns});

  @override
  State<FilterElementWidget> createState() => _FilterElementWidgetState();
}

class _FilterElementWidgetState extends State<FilterElementWidget> {
  @override
  Widget build(BuildContext context) {
    final filterelementProvider = context.watch<FilterElementProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.columns.map((String value) {
          final isSelected = filterelementProvider.getElement == value;

          return ChoiceChip(
            label: GlobalText(
              value,
              color: isSelected ? ColorDefaults.darkBgCard : ColorDefaults.darkCyan,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) filterelementProvider.updateColumn(value);
            },
            // ── Seleccionado: fondo cyan sólido ──────────────────
            selectedColor: ColorDefaults.darkCyan,
            // ── No seleccionado: fondo oscuro transparente ───────
            backgroundColor: ColorDefaults.darkBgHeader,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected
                    ? ColorDefaults.darkCyan
                    : ColorDefaults.darkCyan.withOpacity(0.3),
                width: 1,
              ),
            ),
            // ── Sombra cyan cuando está seleccionado ─────────────
            shadowColor: isSelected
                ? ColorDefaults.darkCyan.withOpacity(0.4)
                : Colors.transparent,
            elevation: isSelected ? 4 : 0,
            pressElevation: 2,
          );
        }).toList(),
      ),
    );
  }
}