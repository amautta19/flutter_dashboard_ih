import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices {
  final supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> getData() async{
    final response = await supabase
      .from('agua_manifold')
      .select();
    return response;
  }
}