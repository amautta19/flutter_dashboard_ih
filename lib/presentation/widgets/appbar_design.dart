import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_day.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_month.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';
import 'package:intl/intl.dart';

class AppbarDesign extends StatelessWidget implements PreferredSizeWidget{
  final String title;       // Título del Appbar
  final String table;       // Tabla para mostrar la última fecha de actualización
  final Color colorBar;     // Color del Appbar
  final bool filterByMonth; // Filtro por Mes, activar o desactivar
  final bool filterByDay;   // Filtro por Día, activar o desactivar
  const AppbarDesign({
    super.key, 
    required this.title, 
    required this.colorBar, 
    required this.table, 
    this.filterByMonth = false, // Valor por defecto desactivado
    this.filterByDay = false    // Valor por defecto desactivado
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: colorBar,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            GlobalText(
              title, 
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: ColorDefaults.darkPrimary,
            ),
            const Spacer(),
            // Obtener el últim dato actualizado de la tabla
            StreamBuilder(
              stream: SupabaseServices().getLastUpdate(table), 
              builder: (context, snapshot){
                if(snapshot.hasData && snapshot.data != null){
                  // Transformar el formato de la fecha
                  DateTime dt = DateTime.parse(snapshot.data!['_time_lima']);
                  String formattedDate = DateFormat('yyy/MM/dd HH:mm').format(dt);
                  return GlobalText(
                    'Actualizado: $formattedDate',
                    fontSize: 20, color: ColorDefaults.whitePrimary, fontWeight: FontWeight.bold,
                  );
                }
                return GlobalText('Sin actualización registrada');
              }
            )
          ],
        ),
      ),
      // Mostrar los filtros
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10,),
            Visibility(
              visible: filterByMonth,
              child: FilterMonthWidget()
            ),
            Visibility(
              visible: filterByDay,
              child: FilterDayWidget()
            ),
            const SizedBox(width: 200,)
          ],
        ),
      ],
    );
  }
  
  @override
  // TODO: implement preferredSize
Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}