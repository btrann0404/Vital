import 'package:flutter/material.dart';
import 'package:gdsc360/utils/authservice.dart';
// Assuming MyButton is a custom widget, import it here if it's not in the same file

class RoleSignup extends StatelessWidget {
  const RoleSignup({super.key});

  Future<void> addRole(String role, BuildContext context) async {
    Auth auth = Auth();
    try {
      await auth.updateUserDetail("role", role);
      print("Role updated to $role.");
      Navigator.pushNamed(
          context, "/mainpage"); // Navigate to main page after updating role
    } catch (e) {
      print("Error updating role: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to ",
                  style: TextStyle(
                      color: Colors.blue[200],
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Vital",
                  style: TextStyle(
                      color: Colors.pink[400],
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "!",
                  style: TextStyle(
                      color: Colors.blue[200],
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 40),
            Text("Are you a...",
                style: TextStyle(color: Colors.blue[200], fontSize: 20)),
            SizedBox(height: 50),
            MaterialButton(
              color: const Color.fromRGBO(144, 202, 249, 1), // Button color
              textColor: Colors.white, // Text color
              onPressed: () => addRole("dependent", context),
              child: const Text('Dependent'),
            ),
            SizedBox(height: 50),
            MaterialButton(
              color: const Color.fromRGBO(144, 202, 249, 1), // Button color
              textColor: Colors.white, // Text color
              onPressed: () => addRole("guardian", context),
              child: const Text('Guardian'),
            ),
          ],
        ),
      ),
    );
  }
}
