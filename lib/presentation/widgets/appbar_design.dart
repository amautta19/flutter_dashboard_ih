import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:flutter_dashboard_ih/presentation/widgets/filter_month.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';
import 'package:intl/intl.dart';

class AppbarDesign extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final Color colorBar;
  const AppbarDesign({super.key, required this.title, required this.colorBar});

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
            StreamBuilder(
              stream: SupabaseServices().getLastUpdate(), 
              builder: (context, snapshot){
                if(snapshot.hasData && snapshot.data != null){
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
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10,),
            FilterMonthWidget(),
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