import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/tables_manifold.dart';
import 'package:flutter_dashboard_ih/supabase_services.dart';
import 'package:provider/provider.dart';
import '../providers/filter_month_provider.dart';

import 'widgets/filter_month.dart';
import 'widgets/graph_manifold.dart';


class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el mes seleccionado
    final selectedMonth = context.watch<FilterMonthProvider>().selectedMonth;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Dashboard Arca Continental'),
        actions: const [FilterMonthWidget(), SizedBox(width: 16)],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: SupabaseServices().getData(), // Tu función de Supabase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay datos disponibles"));
          }

          // --- FILTRADO EN TIEMPO REAL ---
          final filteredData = snapshot.data!.where((item) {
            final fecha = DateTime.parse(item['fecha_operativa']);
            return fecha.month == selectedMonth;
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Pasamos la data filtrada a los widgets que ya tienes
                GraphManifoldWidget(allData: filteredData),
                const SizedBox(height: 20),
                TableManifoldWidget(allData: filteredData),
              ],
            ),
          );
        },
      ),
    );
  }
}