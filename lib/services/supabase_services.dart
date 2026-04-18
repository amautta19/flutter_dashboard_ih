import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices {
  final supabase = Supabase.instance.client;
  Stream<List<Map<String, dynamic>>> getData(String table) {
    return supabase
        .from(table)
        .stream(primaryKey: ['id']) // Asegúrate que 'id' sea tu PK
        .order('fecha_operativa', ascending: false);
  }
Stream<List<Map<String, dynamic>>> getDataByDayOperative(String table, DateTime selectedDate) {
  // Formateamos la fecha de inicio a las 08:00:00
  final String startStr = "${DateFormat('yyyy-MM-dd').format(selectedDate)} 08:00:00";
  
  // Límite final para el filtrado en el cliente (08:00:00 del día siguiente)
  final DateTime endLimit = selectedDate.add(const Duration(days: 1))
      .copyWith(hour: 8, minute: 0, second: 0);

  return supabase
      .from(table)
      .stream(primaryKey: ['id'])
      // Usamos GTE (Greater Than or Equal) para incluir el registro de las 08:00:00
      .gte('_time_lima', startStr) 
      .order('_time_lima', ascending: true)
      .map((list) {
        // Filtramos el final del día operativo en el cliente 
        // para no chocar con la limitación de un solo filtro del SDK
        return list.where((item) {
          final DateTime itemTime = DateTime.parse(item['_time_lima']);
          return itemTime.isBefore(endLimit);
        }).toList();
      });
}
  Stream<Map<String, dynamic>?> getLastUpdate(String table) {
    final streamQuery = supabase
      .from(table)
      .stream(primaryKey: ['id'])
      .order('_time_lima', ascending: false)
      .limit(1);
    final Stream<Map<String, dynamic>?> response = streamQuery.map((data){
      if(data.isNotEmpty){
        return data.first;
      }
      return null;
    });
    return response;
  }

  // En tu clase SupabaseServices
  Future<List<Map<String, dynamic>>> getUmbrales() async {
    // Traemos toda la tabla sin filtros para tener todos los argumentos
    final response = await supabase.from('umbrales').select();
    return response;
  }
}