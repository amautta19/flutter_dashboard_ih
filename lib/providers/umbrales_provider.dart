import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';

class UmbralesProvider with ChangeNotifier{
  List<Map<String, dynamic>> _tablaUmbrales = []; // Variable donde se guardaran los datos de los umbrales

  bool _isLoading = false; // Status de carga

  List<Map<String, dynamic>> get tablaUmbrales => _tablaUmbrales;
  bool get isLoading => _isLoading;

  // Función para obtener los umbrales desde supabase
  Future<void> actualizarUmbrales() async{
    _isLoading = true;
    notifyListeners();
    try{
      _tablaUmbrales = await SupabaseServices().getUmbrales(); // Se llama al servicio de supabase
      print('Tabla umbrales cargado');
    } catch (e){
      print('Error al obtener los umbrales_ $e');

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  dynamic obtenerUmbral(String nombreUmbral, String columna){
    try{
      final fila = _tablaUmbrales.firstWhere((u) => u['argumento'] == nombreUmbral);
      return fila[columna];
    } catch (e){
      return null;
    }
  }
}