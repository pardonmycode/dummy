import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: const [
          ListTile(title: Text('Thema')),
          ListTile(title: Text('Sprache')),
          ListTile(title: Text('Konto')),
        ],
      ),
    );
  }
}
