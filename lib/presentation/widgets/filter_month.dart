import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: ColorDefaults.darkBgHeader,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorDefaults.darkCyan, width: 1),
          boxShadow: [
            BoxShadow(
              color: ColorDefaults.darkCyan.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Ícono calendario ────────────────────────────────
              const Icon(
                Icons.calendar_month_rounded,
                color: ColorDefaults.darkCyan,
                size: 18,
              ),
              const SizedBox(width: 8),
              GlobalText(
                'Filtrar Mes:',
                color: ColorDefaults.darkCyan,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              // ── Divisor ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: VerticalDivider(
                  color: ColorDefaults.darkCyan.withOpacity(0.3),
                  thickness: 1,
                ),
              ),

              // ── Dropdown ────────────────────────────────────────
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: monthProvider.getMonth,
                  dropdownColor: ColorDefaults.darkBgHeader,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: ColorDefaults.darkCyan,
                  ),
                  style: TextStyle(
                    color: ColorDefaults.whitePrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      monthProvider.updateMonth(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 1,  child: Text("Enero")),
                    DropdownMenuItem(value: 2,  child: Text("Febrero")),
                    DropdownMenuItem(value: 3,  child: Text("Marzo")),
                    DropdownMenuItem(value: 4,  child: Text("Abril")),
                    DropdownMenuItem(value: 5,  child: Text("Mayo")),
                    DropdownMenuItem(value: 6,  child: Text("Junio")),
                    DropdownMenuItem(value: 7,  child: Text("Julio")),
                    DropdownMenuItem(value: 8,  child: Text("Agosto")),
                    DropdownMenuItem(value: 9,  child: Text("Septiembre")),
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