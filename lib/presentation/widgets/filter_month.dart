import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/filter_month_provider.dart';

class FilterMonthWidget extends StatelessWidget {
  const FilterMonthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final monthProvider = Provider.of<FilterMonthProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButton<int>(
        value: monthProvider.selectedMonth,
        dropdownColor: const Color(0xFF1E1E26),
        underline: const SizedBox(), // Quita la línea de abajo
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        onChanged: (int? newValue) {
          if (newValue != null) {
            monthProvider.updateMonth(newValue);
          }
        },
      ),
    );
  }
}