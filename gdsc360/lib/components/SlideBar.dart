import 'package:flutter/material.dart';
import 'package:gdsc360/utils/authservice.dart';

class SlideBar extends StatelessWidget {
  Auth auth = Auth();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(
                  height: 50,
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () => Navigator.pushNamed(context, '/profilepage'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.mic),
                  title: Text('Speech Visual'),
                  onTap: () => Navigator.pushNamed(context, '/speech'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                Divider(),
                ListTile(
                  title: Text('Exit'),
                  leading: Icon(Icons.exit_to_app),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Sign Out Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () {
                auth.signOutAuth(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
