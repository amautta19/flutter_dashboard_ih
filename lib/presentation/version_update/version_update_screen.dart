import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dashboard_ih/defaults/color_defaults.dart';
import 'package:flutter_dashboard_ih/defaults/text_global.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VersionUpdateScreen extends StatefulWidget {
  final String versionNew;
  const VersionUpdateScreen({super.key, required this.versionNew});

  @override
  State<VersionUpdateScreen> createState() => _VersionUpdateScreenState();
}

class _VersionUpdateScreenState extends State<VersionUpdateScreen> {
  bool _isDownloading = false;

  // 1. Diálogo de confirmación
  Future<void> _confirmarActualizacion() async {
    bool? aceptar = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Obliga a interactuar con los botones
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B2B2B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text("Confirmar Actualización", style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: const Text(
            "Se cerrará y se abrirá la aplicación en automático.\n\n¡No interrumpir el proceso hasta que la aplicación se reinicie!",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("ACEPTAR", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (aceptar == true) {
      _ejecutarActualizacion();
    }
  }

  // 2. Lógica de descarga y ejecución de script
  Future<void> _ejecutarActualizacion() async {
    setState(() => _isDownloading = true);

    try {
      // Obtener URL de Supabase Storage
      final String urlDescarga = Supabase.instance.client.storage
          .from('updates')
          .getPublicUrl('update.zip');

      // Ruta local en el directorio de la aplicación
      String pathZip = "${Directory.current.path}/update.zip";

      // Descarga con Dio (evitando caché con timestamp)
      await Dio().download(
        "$urlDescarga?t=${DateTime.now().millisecondsSinceEpoch}",
        pathZip,
      );

      // Lanzar script de PowerShell (Debe existir update.ps1 en la raíz)
      await Process.start('powershell', [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        'update.ps1',
      ]);

      // Cerrar app para permitir que el script reemplace los archivos
      exit(0);
    } catch (e) {
      setState(() => _isDownloading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Error crítico: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentBlue = Color(0xFF0078D4);
    const cardColor = Color(0xFF2B2B2B);

    return Scaffold(
      backgroundColor: ColorDefaults.darkPrimary,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 400),
          padding: const EdgeInsets.all(40.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update_alt_rounded, size: 70, color: accentBlue),
              const SizedBox(height: 20),
              const Text(
                'Actualización Disponible',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              GlobalText(
                'Se requiere actualizar la aplicación para asegurar la integridad de los datos y continuar con el monitoreo.',
                textAlign: TextAlign.center,
                color: ColorDefaults.whitePrimary.withOpacity(0.7),
                fontSize: 15,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Versión de destino: ${widget.versionNew}',
                  style: const TextStyle(
                    color: accentBlue,
                    fontFamily: 'Consolas',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  // Si está descargando, el botón se deshabilita (null)
                  onPressed: _isDownloading ? null : _confirmarActualizacion,
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.auto_fix_high_rounded),
                  label: Text(
                    _isDownloading ? 'PROCESANDO...' : 'ACTUALIZAR AHORA',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}