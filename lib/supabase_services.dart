import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices {
  final supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> getData() async{
    final response = await supabase
      .from('agua_manifold_diario_v2')
      .select()
      .order('fecha_operativa', ascending: false);
    return response;
  }
  Future<List<Map<String, dynamic>>> getDataByDayOperative(DateTime selectedDate) async {
    // Formateamos el inicio: 07:00:00 del día seleccionado
    final String start = "${DateFormat('yyyy-MM-dd').format(selectedDate)} 08:00:00";
    
    // Calculamos el final: 07:00:00 del día siguiente
    final DateTime nextDay = selectedDate.add(const Duration(days: 1));
    final String end = "${DateFormat('yyyy-MM-dd').format(nextDay)} 08:00:00";

    final response = await supabase
        .from('agua_manifold')
        .select()
        .filter('_time_lima', 'gte', start)
        .filter('_time_lima', 'lt', end) // 'lt' es "menor que" para no repetir las 07:00
        .order('_time_lima', ascending: true);
        
    return response;
  }
  Future<Map<String, dynamic>?> getLastUpdate() async{
    final response = await supabase
      .from('agua_manifold')
      .select('_time_lima')
      .order('_time_lima', ascending: false)
      .limit(1)
      .single();
    return response;
  }
}