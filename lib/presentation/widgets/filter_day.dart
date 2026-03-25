import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:intl/intl.dart';

class FilterDayWidget extends StatelessWidget {
  const FilterDayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dayProvider = context.watch<FilterDayProvider>();
    
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: dayProvider.selectedDate,
          firstDate: DateTime(2025),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: ColorDefaults.primaryBlue,
                  onPrimary: ColorDefaults.whitePrimary,
                  onSurface: ColorDefaults.darkPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          dayProvider.updateDate(picked);
        }
      },
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: ColorDefaults.whitePrimary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorDefaults.darkPrimary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ETIQUETA A LA IZQUIERDA
            Text(
              'Fecha Operativa:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: ColorDefaults.darkPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 10),
            VerticalDivider( // Una pequeña línea separadora vertical
              color: ColorDefaults.darkPrimary.withOpacity(0.2),
              indent: 10,
              endIndent: 10,
            ),
            const SizedBox(width: 10),
            Icon(Icons.calendar_today_rounded, 
                size: 16, 
                color: ColorDefaults.primaryBlue),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd/MM/yyyy').format(dayProvider.selectedDate),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorDefaults.darkPrimary,
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.arrow_drop_down, color: ColorDefaults.darkPrimary),
          ],
        ),
      ),
    );
  }
}