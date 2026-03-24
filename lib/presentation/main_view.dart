import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_element.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/tables_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/graph_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_month.dart';
import 'package:flutter_dashboard_ih/supabase_services.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el mes seleccionado para que el FutureBuilder se refresque al cambiarlo
    final selectedMonth = context.watch<FilterMonthProvider>().selectedMonth;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Dashboard Arca Continental',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlobalText('Filtrar por Mes', color: ColorDefaults.whitePrimary,fontSize: 16,),
                  const SizedBox(width: 10,),
                  FilterMonthWidget(),
                ],
              ),
              const SizedBox(height: 20,),
              FutureBuilder<List<dynamic>>(
                // El build se dispara cuando cambian los providers, refrescando el Future si es necesario
                future: SupabaseServices().getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: ColorDefaults.primaryBlue));
                  }
              
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error de conexión", style: TextStyle(color: Colors.red)));
                  }
              
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: GlobalText('Sin datos disponibles', fontSize: 24));
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
                      child: GlobalText('No hay datos para este mes seleccionado', fontSize: 24,),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
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
                        const SizedBox(height: 20,),
                        Center(child: GraphColumnSelector()),
                        const SizedBox(height: 20,),
                        GraphManifoldWidget(allData: filteredData,), 
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}