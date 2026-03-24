import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_element.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';

// Widgets
import 'package:flutter_dashboard_ih/presentation/widgets/tables_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/graph_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_month.dart';
// Importa aquí donde tengas guardado el GraphColumnSelector que me pasaste

// Servicios
import 'package:flutter_dashboard_ih/supabase_services.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el mes seleccionado para que el FutureBuilder se refresque al cambiarlo
    final selectedMonth = context.watch<FilterMonthProvider>().selectedMonth;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'Dashboard Arca Continental',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          // Tu nuevo Selector de Columnas
          const GraphColumnSelector(),
          
          const SizedBox(width: 12),
          
          // Selector de Mes
          const FilterMonthWidget(),
          
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        // El build se dispara cuando cambian los providers, refrescando el Future si es necesario
        future: SupabaseServices().getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error de conexión", style: TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Sin datos disponibles", style: TextStyle(color: Colors.white)));
          }

          // Filtrado por mes (Lógica operativa)
          final filteredData = snapshot.data!.where((item) {
            try {
              final fecha = DateTime.parse(item['fecha_operativa']);
              return fecha.month == selectedMonth;
            } catch (e) {
              return false;
            }
          }).toList();

          if (filteredData.isEmpty) {
            return const Center(
              child: Text("No hay registros para este mes", style: TextStyle(color: Colors.white70)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gráfica de Tendencia
                GraphManifoldWidget(allData: filteredData,), 
                
                const SizedBox(height: 30),
                
                // Tabla de detalles
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    "Registro de Lecturas - Planta",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                
                // Pasamos los datos filtrados a la tabla
                TableManifoldWidget(allData: filteredData),
              ],
            ),
          );
        },
      ),
    );
  }
}