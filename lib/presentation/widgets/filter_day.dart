import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:intl/intl.dart';

class FilterDayWidget extends StatelessWidget {
  const FilterDayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dayProvider = context.watch<FilterDayProvider>();

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Icons.calendar_today_rounded,
                color: ColorDefaults.darkCyan,
                size: 18,
              ),
              const SizedBox(width: 8),
              GlobalText(
                'Fecha Operativa:',
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
              // ── Fecha + tap ──────────────────────────────────────
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: dayProvider.getDate,
                    firstDate: DateTime(2025),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: ColorDefaults.darkCyan,
                            onPrimary: ColorDefaults.darkBgCard,
                            surface: ColorDefaults.darkBgHeader,
                            onSurface: ColorDefaults.darkTextPrimary,
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
                child: Row(
                  children: [
                    GlobalText(
                      DateFormat('dd/MM/yyyy').format(dayProvider.getDate),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorDefaults.darkTextPrimary,
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: ColorDefaults.darkCyan,
                    ),
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