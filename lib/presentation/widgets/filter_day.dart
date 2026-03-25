import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:intl/intl.dart';

class FilterDayWidget extends StatelessWidget {
  const FilterDayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dayProvider = context.watch<FilterDayProvider>();
    
    return ElevatedButton.icon(
      icon: const Icon(Icons.calendar_month),
      label: Text(DateFormat('dd/MM/yyyy').format(dayProvider.selectedDate)),
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: dayProvider.selectedDate,
          firstDate: DateTime(2026),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          dayProvider.updateDate(picked);
        }
      },
    );
  }
}