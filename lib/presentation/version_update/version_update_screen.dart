import 'package:flutter/material.dart';

class VersionUpdateScreen extends StatefulWidget {
  final String versionNew;
  const VersionUpdateScreen({super.key, required this.versionNew});

  @override
  State<VersionUpdateScreen> createState() => _VersionUpdateScreenState();
}

class _VersionUpdateScreenState extends State<VersionUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Se requiere actualizar la versión'),
            Text(widget.versionNew)
          ],
        ),
      ),
    );
  }
}