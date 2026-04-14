import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/services/supabase_services.dart';

class UmbralesProvider with ChangeNotifier{
  List<Map<String, dynamic>> _tablaUmbrales = [];

  bool _isLoading = false;

  List<Map<String, dynamic>> get tablaUmbrales => _tablaUmbrales;
  bool get isLoading => _isLoading;

  Future<void> actualizarUmbrales() async{
    _isLoading = true;
    notifyListeners();
    try{
      _tablaUmbrales = await SupabaseServices().getUmbrales();
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