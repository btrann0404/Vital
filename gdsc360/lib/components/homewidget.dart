import 'package:flutter/material.dart';

class HomeWidget extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor; // New property for icon color
  final Color textColor; // New property for text color
  final VoidCallback onPressed;

  const HomeWidget({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor, // Initialize icon color
    required this.textColor, // Initialize text color
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(16),
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: iconColor, size: 48), // Use iconColor here
            SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor, // Use textColor here
              ),
            ),
          ],
        ),
      ),
    );
  }
}
