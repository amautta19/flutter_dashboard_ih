import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/lavadoras/lavadoras_bragraph.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/appbar_design.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_day.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/navbar_design.dart';
import 'package:flutter_dashboard_ih/providers/filter_day_provider.dart';
import 'package:flutter_dashboard_ih/providers/filter_month_provider.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';
import 'package:provider/provider.dart';

class LavadorasScreen extends StatefulWidget {
  const LavadorasScreen({super.key});

  @override
  State<LavadorasScreen> createState() => _LavadorasScreenState();
}

class _LavadorasScreenState extends State<LavadorasScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<FilterMonthProvider>().getMonth;
    final dayProvider = context.watch<FilterDayProvider>().getDate;
    final windowSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppbarDesign(
        title: 'Consumo Agua Lavadoras - Pucusana', 
        colorBar: Colors.redAccent, 
        table: 'tiempo_efectivo'
      ),
      drawer: NavbarDisgn(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            children: [
              FilterDayWidget(),
              StreamBuilder<List<dynamic>>(
                stream: SupabaseServices().getDataByDayOperative('tiempo_efectivo', dayProvider), 
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: windowSize.height * 0.42,
                      width: windowSize.width * 0.38,
                      child: Center(child: CircularProgressIndicator(color: ColorDefaults.primaryBlue,),),
                    );
                  }
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: windowSize.height * 0.42,
                      width: windowSize.width * 0.38,
                      child: Center(child: GlobalText('Error al obtener los datos! ${snapshot.error}', fontSize: 24, color: Colors.red,),),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // return Center(child: GlobalText('Sin datos disponibles entre ese rango de fechas', fontSize: 24));
                    return SizedBox(
                      height: windowSize.height * 0.42,
                      width: windowSize.width * 0.38,
                      child: Center(child: GlobalText('Sin datos disponibles para el día seleccionado', fontSize: 24,)),
                    );
                  }
                  // --- AQUÍ ESTÁ EL CAMBIO ---
                  return Column(
                    children: [
                      BarGraphDiaryMulti(allData: snapshot.data!),
                      SizedBox(height: 50,),
                    ],
                  );
                }
              )
            ],
          ),
        ),
      )
    );
  }
}