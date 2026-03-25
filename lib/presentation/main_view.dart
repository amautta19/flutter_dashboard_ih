import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/distribution_chart.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_day.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_element.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart'; // Agregado
import 'package:flutter_dashboard_ih/presentation/widgets/tables_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/graph_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_month.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/line_chart.dart';
import 'package:flutter_dashboard_ih/supabase_services.dart';
class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<FilterMonthProvider>().selectedMonth;
    // Obtenemos el día seleccionado para el filtro de horas
    final selectedDate = context.watch<FilterDayProvider>().selectedDate;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorDefaults.darkPrimary,
        elevation: 0,
        title: GlobalText('Consumo Planta Pucusana', fontSize: 28, fontWeight: FontWeight.bold, color: ColorDefaults.primaryBlue,),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlobalText('Filtrar por Mes', color: ColorDefaults.whitePrimary, fontSize: 16,),
              const SizedBox(width: 10,),
              FilterMonthWidget(),
              const SizedBox(width: 200,)
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            children: [
              FutureBuilder<List<dynamic>>(
                future: SupabaseServices().getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: ColorDefaults.primaryBlue));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: GlobalText('Error al obtener los datos!', fontSize: 24, color: Colors.red,));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: GlobalText('Sin datos disponibles', fontSize: 24));
                  }

                  final filteredData = snapshot.data!.where((item) {
                    try {
                      final fecha = DateTime.parse(item['fecha_operativa']);
                      return fecha.month == selectedMonth;
                    } catch (e) { return false; }
                  }).toList();

                  if (filteredData.isEmpty) {
                    return const Center(child: GlobalText('No hay datos para este mes seleccionado', fontSize: 24,));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GlobalText('Registro de Consumo Diario Manifold - Planta Pucusana', fontSize: 16, fontWeight: FontWeight.bold, color: ColorDefaults.secundaryBlue,),
                          const SizedBox(width: 200,),
                        ],
                      ),
                      const SizedBox(height: 5,),
                      Row(
                        children: [
                          TableManifoldWidget(allData: filteredData),
                          const Spacer(),
                          DistributionBarChart(allData: filteredData)
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Center(child: GraphColumnSelector(),),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          GraphManifoldWidget(allData: filteredData),
                          const Spacer(),
                          // --- SECCIÓN DE LA GRÁFICA POR HORAS CON SU FILTRO ---
                          Column(
                            children: [
                              Row(
                                children: [
                                  GlobalText('Filtrar Día: ', color: ColorDefaults.darkPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                                  FilterDayWidget(), // Botón para elegir el día
                                ],
                              ),
                              const SizedBox(height: 5),
                              FutureBuilder(
                                future: SupabaseServices().getDataByDayOperative(selectedDate), 
                                builder: (context, snapshotHour) {
                                  if (snapshotHour.connectionState == ConnectionState.waiting) {
                                    return SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.33,
                                      height: 400,
                                      child: Center(child: CircularProgressIndicator(color: ColorDefaults.primaryBlue))
                                    );
                                  }
                                  if (!snapshotHour.hasData || snapshotHour.data!.isEmpty) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width * 0.33,
                                      height: 400,
                                      alignment: Alignment.center,
                                      child: const GlobalText('No hay datos para esta fecha'),
                                    );
                                  }
                                  return LineTrendChart(allData: snapshotHour.data!);
                                }
                              ),
                            ],
                          )
                        ],
                      )
                    ],
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