import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          backgroundColor: const Color.fromARGB(255, 142, 217, 252),
        ),
        body: Text("This will be settings"));
  }
}
