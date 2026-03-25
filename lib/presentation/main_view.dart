import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/distribution_chart.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_day.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_element.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/tables_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/graph_manifold.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_month.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/line_chart.dart';
import 'package:flutter_dashboard_ih/supabase_services.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    // Escuchamos el mes. Si cambia el mes, se refresca todo (esto es correcto).
    final selectedMonth = context.watch<FilterMonthProvider>().selectedMonth;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorDefaults.darkPrimary,
        elevation: 0,
        title: GlobalText(
          'Consumo Planta Pucusana', 
          fontSize: 28, 
          fontWeight: FontWeight.bold, 
          color: ColorDefaults.primaryBlue,
        ),
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
              // --- FUTURE BUILDER PRINCIPAL (DEPENDE DEL MES) ---
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
                      Row(
                        children: [
                          Column(
                            children: [
                              GraphColumnSelector(),
                              const SizedBox( height: 5,),
                              GraphManifoldWidget(allData: filteredData)
                            ],
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              Consumer<FilterDayProvider>(
                                builder: (context, dayProvider, child){
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          GlobalText('Filtrar Día', fontSize: 16,),
                                          FilterDayWidget()
                                        ],
                                      ),
                                      const SizedBox(height: 5,),
                                      FutureBuilder(
                                        future: SupabaseServices().getDataByDayOperative(dayProvider.selectedDate), 
                                        builder: (context, snapshot){
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return SizedBox(
                                              height: windowSize.height * 0.42,
                                              width: windowSize.width * 0.33,
                                              child: Center(child: CircularProgressIndicator(color: ColorDefaults.primaryBlue,),),
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return SizedBox(
                                             height: windowSize.height * 0.42,
                                              width: windowSize.width * 0.33,
                                              child: Center(child: GlobalText('Error al obtener los datos! ${snapshot.error}', fontSize: 24, color: Colors.red,),),
                                            );
                                          }
                                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                            // return Center(child: GlobalText('Sin datos disponibles entre ese rango de fechas', fontSize: 24));
                                            return SizedBox(
                                              height: windowSize.height * 0.42,
                                              width: windowSize.width * 0.33,
                                              child: Center(child: GlobalText('Sin datos disponibles para el día seleccionado', fontSize: 24,)),
                                            );
                                          }
                                          return LineTrendChart(allData: snapshot.data!);
                                        }
                                      )
                                    ],
                                  );
                                }
                              )
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