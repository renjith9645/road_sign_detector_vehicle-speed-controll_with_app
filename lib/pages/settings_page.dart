import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String ip;

  const SettingsPage({
    super.key,
    required this.ip,
  });

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  bool autoRefresh = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SETTINGS"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.wifi,
            ),
            title: const Text(
              "Robot IP",
            ),
            subtitle: Text(
              widget.ip,
            ),
          ),

          SwitchListTile(
            title: const Text(
              "Auto Refresh",
            ),
            value: autoRefresh,
            onChanged: (value) {
              setState(() {
                autoRefresh = value;
              });
            },
          ),

          const AboutListTile(
            applicationName:
                "Robot Controller",
            applicationVersion: "1.0",
          ),
        ],
      ),
    );
  }
}