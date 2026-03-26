import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices {
  final supabase = Supabase.instance.client;
  Stream<List<Map<String, dynamic>>> getData() {
    return supabase
        .from('agua_manifold_diario_v2')
        .stream(primaryKey: ['id']) // Asegúrate que 'id' sea tu PK
        .order('fecha_operativa', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> getDataByDayOperative(DateTime selectedDate) {
    // 1. Definimos los límites de tiempo igual que antes
    final String startStr = "${DateFormat('yyyy-MM-dd').format(selectedDate)} 08:00:00";
    final DateTime nextDay = selectedDate.add(const Duration(days: 1));
    final String endStr = "${DateFormat('yyyy-MM-dd').format(nextDay)} 08:00:00";

    // Convertimos a DateTime para comparar más fácilmente en Dart
    final DateTime startTime = DateTime.parse(startStr);
    final DateTime endTime = DateTime.parse(endStr);

    return supabase
        .from('agua_manifold')
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