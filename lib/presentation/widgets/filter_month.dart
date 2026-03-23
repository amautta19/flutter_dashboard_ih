import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:provider/provider.dart';

class FilterMonth extends StatefulWidget {
  const FilterMonth({super.key});

  @override
  State<FilterMonth> createState() => _FilterMonthState();
}

class _FilterMonthState extends State<FilterMonth> {
  final List<String> _meses = ['Todos', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
  @override
  Widget build(BuildContext context) {

    final providerMonth = Provider.of<FilterMonthProvider>(context); 

    return Card(
      color: ColorDefaults.primaryBlue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Row(
          children: [
            Text('titulo'),
            DropdownButton<String>(
              items: _meses.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              value: providerMonth.getMonth,
              onChanged: (val){
                providerMonth.updateMonth(val!);
              },
            )
          ],
        ),
      ),
    );
  }
}