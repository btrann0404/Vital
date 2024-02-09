import 'package:flutter/material.dart';

class Healthpage extends StatelessWidget {
  const Healthpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: Icon(Icons.directions_walk),
                  title: Text('Steps'),
                  subtitle: Text('8500 today'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Heart Rate'),
                  subtitle: Text('75 bpm'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.hotel),
                  title: Text('Sleep'),
                  subtitle: Text('7 hours last night'),
                ),
              ),
              // Add more health cards here
            ],
          ),
        ),
      ),
    );
  }
}
