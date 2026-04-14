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
    // 1. Definimos los límites de tiempo igual que antes
    final String startStr = "${DateFormat('yyyy-MM-dd').format(selectedDate)} 08:00:00";
    final DateTime nextDay = selectedDate.add(const Duration(days: 1));
    final String endStr = "${DateFormat('yyyy-MM-dd').format(nextDay)} 08:00:00";

    // Convertimos a DateTime para comparar más fácilmente en Dart
    final DateTime startTime = DateTime.parse(startStr);
    final DateTime endTime = DateTime.parse(endStr);

    return supabase
        .from(table)
        .stream(primaryKey: ['id']) // Asegúrate de que 'id' sea tu PK
        .order('_time_lima', ascending: true)
        .map((List<Map<String, dynamic>> event) {
          // 2. Filtramos la lista en tiempo real en el cliente
          return event.where((item) {
            final DateTime itemTime = DateTime.parse(item['_time_lima']);
            return itemTime.isAtSameMomentAs(startTime) || 
                  (itemTime.isAfter(startTime) && itemTime.isBefore(endTime));
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