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
  Future<List<Map<String, dynamic>>> getDataHour() async{
    final response = await supabase
      .from('agua_manifold')
      .select();
    return response;
  }
}