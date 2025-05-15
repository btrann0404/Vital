import 'package:flutter/material.dart';

class HealthCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const HealthCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor
    });
  

  @override
  Widget build(BuildContext context) {
    return Card(
                child: ListTile(
                  leading: Icon(icon, size: 70, color: iconColor,),
                  title: Text(title, style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(subtitle),
                  isThreeLine: true,
                ),
              );
  }
}