import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc360/firebase_options.dart';
import 'package:gdsc360/pages/HomePage.dart';
import 'package:gdsc360/pages/MainPage.dart';
import 'package:gdsc360/pages/Login.dart';
import 'package:gdsc360/pages/MapPage.dart';
import 'package:gdsc360/pages/ProfilePage.dart';
import 'package:gdsc360/pages/RoleSignup.dart';
import 'package:gdsc360/pages/SettingsPage.dart';
import 'package:gdsc360/pages/Signup.dart';
import 'package:gdsc360/pages/Speech.dart';
import 'package:gdsc360/pages/HealthPage.dart';
import 'package:gdsc360/pages/MessagePage.dart';
import 'package:gdsc360/themes/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
                builder:
                    (context, AsyncSnapshot<DocumentSnapshot> roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.done) {
                    if (roleSnapshot.hasData) {
                      var userData =
                          roleSnapshot.data!.data() as Map<String, dynamic>?;
                      String? userRole = userData?['role'];

                      if (userRole == null || userRole.isEmpty) {
                        return const RoleSignup();
                      } else {
                        return const MainPage();
                      }
                    }
                    return const Login(); // No user data found, navigate to Login
                  }
                  return const Login(); // Still loading user data
                },
              );
            } else {
              return const Login(); // No user logged in
            }
          }
          return const Login(); // Waiting for connection state
        },
      ),
      theme: lightMode,
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/mainpage': (context) => const MainPage(),
        '/homepage': (context) => const HomePage(),
        '/speech': (context) => SpeechScreen(),
        '/messagepage': (context) => const MessagePage(),
        '/healthpage': (context) => const Healthpage(),
        '/mappage': (context) => const MapPage(),
        '/rolesignup': (context) => const RoleSignup(),
        '/profilepage': (context) => ProfilePage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
