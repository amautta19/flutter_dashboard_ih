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
  bool _isDownloading = false; // Estado visual para el botón
  bool _estaDescargando = false;
  Future<void> _actualizarSistema() async {
    setState(() => _estaDescargando = true);

    try {
      // 2. OBTENER URL DEL ARCHIVO DESDE EL STORAGE
      // 'updates' es el nombre de tu bucket y 'update.zip' el archivo
      final String urlDescarga = Supabase.instance.client
          .storage
          .from('updates')
          .getPublicUrl('update.zip');

      // 3. RUTA LOCAL (Donde se guarda temporalmente)
      String pathZip = "${Directory.current.path}/update.zip";

      // 4. DESCARGAR EL ARCHIVO (Usamos Dio)
      // Agregamos el timestamp para saltarnos el cache del firewall de la empresa
      await Dio().download(
        "$urlDescarga?t=${DateTime.now().millisecondsSinceEpoch}", 
        pathZip
      );

      // 5. LANZAR EL SCRIPT DE POWERSHELL
      // Importante: El archivo 'update.ps1' debe estar en la carpeta de la app
      await Process.start('powershell', [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        'update.ps1'
      ]);

      // 6. CERRAR LA APP PARA EL REEMPLAZO
      exit(0);

    } catch (e) {
      setState(() => _estaDescargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el color oscuro de fondo que ya tienes definido
    final backgroundColor = ColorDefaults.darkPrimary; 
    const accentBlue = Color(0xFF0078D4); // Azul estándar de Windows
    const cardColor = Color(0xFF2B2B2B); // Un gris ligeramente más claro que el fondo

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          // Limitamos el ancho para que no se vea gigante en monitores 1080p
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 450),
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10), // Borde sutil estilo Windows 11
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono grande indicando actualización
              const Icon(
                Icons.system_update_alt_rounded,
                size: 80,
                color: accentBlue,
              ),
              const SizedBox(height: 24),
              
              // Título Principal
              const Text(
                'Actualización Obligatoria',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white, // O ColorDefaults.whitePrimary
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              GlobalText(
                'Se requiere actualizar la aplicación para continuar con el monitoreo.',
                textAlign: TextAlign.center,
                color: ColorDefaults.whitePrimary.withOpacity(0.7),
                fontSize: 16,
              ),
              const SizedBox(height: 10),
              
              // Cuadro con la versión nueva
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Nueva versión: ${widget.versionNew}',
                  style: const TextStyle(
                    color: accentBlue,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Consolas', // Toque técnico
                  ),
                ),
              ),
              
              const Spacer(), // Empuja el botón hacia abajo

              // Botón de Acción Principal (Estilo Windows Elevado)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  // onPressed: _isDownloading 
                  //   ? null // Deshabilitado si está "descargando"
                  //   : () {
                  //       // AQUÍ IRÁ LA LÓGICA LUEGO
                  //       setState(() {
                  //         _isDownloading = true;
                  //       });
                  //       print('Iniciando descarga de versión ${widget.versionNew}...');
                  //     },
                  onPressed: _actualizarSistema,
                  icon: _isDownloading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2,)
                      )
                    : const Icon(Icons.download_rounded),
                  label: Text(
                    _isDownloading 
                      ? 'DESCARGANDO E INSTALANDO...' 
                      : 'ACTUALIZAR APLICACIÓN',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    foregroundColor: Colors.white,
                    elevation: 4,
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