import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/WUR/bar_graph_wur_monthly.dart';
import 'package:flutter_dashboard_ih/presentation/WUR/card_wur.dart';
import 'package:flutter_dashboard_ih/presentation/WUR/table_wur_mensual.dart';
import 'package:flutter_dashboard_ih/presentation/WUR/table_wur_semanal.dart';
import 'package:flutter_dashboard_ih/presentation/WUR/wur_bar_graph_diary.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/appbar_design.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/bar_graph_hours.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_day.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_month.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_design.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_element_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';
import 'package:provider/provider.dart';

class WurScreen extends StatefulWidget {
  const WurScreen({super.key});

  @override
  State<WurScreen> createState() => _WurScreenState();
}

class _WurScreenState extends State<WurScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<FilterElementProvider>().updateColumn('wur');
    });
  }
  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<FilterMonthProvider>().getMonth;
    final windowSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppbarDesign(
        title: 'WUR - PLANTA PUCUSANA', 
        colorBar: Colors.redAccent, 
        table: 'wur_hora',
        filterByMonth: false,
      ),
      drawer: NavbarDisgn(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardWur(valorActual: 1.52, umbral: 1.55,),
                  const SizedBox(width: 10,),
                  StreamBuilder<List<dynamic>>(
                    stream: SupabaseServices().getWurMensual(), // Llamada a la nueva vista
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
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BarGraphWurMonthly(
                            allData: snapshot.data!,
                            unidadM: '',
                            titleM: 'WUR Mensual',
                            maxLabel: 12,
                          ),
                          const SizedBox(width: 5,),
                          TableWurMonthly(allData: snapshot.data!, width: 0.15,),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 5,),
                  StreamBuilder<List<dynamic>>(
                  stream: SupabaseServices().getWurSemana(), // Llamada a la nueva vista
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
                    return TableWurSemanal(allData: snapshot.data!);
                  },
                ),
              ]
              ),
              FilterMonthWidget(),
              // --- FUTURE BUILDER PRINCIPAL (DEPENDE DEL MES) ---
              StreamBuilder<List<dynamic>>(
                stream: SupabaseServices().getData('wur_diario'),
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
                      // GlobalText('Registro de WUR - Planta Pucusana', fontSize: 16, fontWeight: FontWeight.bold, color: ColorDefaults.secundaryBlue,),
                      WurBarGraphDiary(
                        allData: filteredData,
                        titleM: 'WUR',
                        unidadM: '',
                        widthGraph: 0.5,
                        maxLabel: 10,),
                      const SizedBox(height: 10,),
                    ],
                  );
                },
              ),
              FilterDayWidget(),
              const SizedBox(height: 10,),
              Consumer<FilterDayProvider>(
                builder: (context, dayProvider, child){
                  return Column(
                    children: [
                      StreamBuilder(
                        stream: SupabaseServices().getDataByDayOperative('wur_hora', dayProvider.getDate), 
                        builder: (context, snapshot){
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(
                              height: windowSize.height * 0.42,
                              width: windowSize.width * 0.8,
                              child: Center(child: CircularProgressIndicator(color: ColorDefaults.primaryBlue,),),
                            );
                          }
                          if (snapshot.hasError) {
                            return SizedBox(
                              height: windowSize.height * 0.42,
                              width: windowSize.width * 0.8,
                              child: Center(child: GlobalText('Error al obtener los datos! ${snapshot.error}', fontSize: 24, color: Colors.red,),),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            // return Center(child: GlobalText('Sin datos disponibles entre ese rango de fechas', fontSize: 24));
                            return SizedBox(
                              height: windowSize.height * 0.42,
                              width: windowSize.width * 0.8,
                              child: Center(child: GlobalText('Sin datos disponibles para el día seleccionado', fontSize: 24,)),
                            );
                          }
                          return BarGraphHours(allData: snapshot.data!, widthGraph: 0.5,);
                        }
                      )
                    ],
                  );
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}