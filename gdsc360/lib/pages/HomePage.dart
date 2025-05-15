import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc360/components/homewidget.dart';
import 'package:gdsc360/pages/MainPage.dart';
import 'package:gdsc360/pages/Speech.dart';
import 'package:http/http.dart' as http;
import 'package:gdsc360/utils/authservice.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Error: Server responded with status code ${response.statusCode}";
      }
    } catch (e) {
      return "Embrace today with positivity and determination!"; //placeholder
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      final Auth auth = Auth();
      auth.signOutAuth(context);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    Auth auth = Auth();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<Map<String, dynamic>?>(
                        future: auth.currUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData) {
                            var userData = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Back, ${userData['name']}!",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          } else {
                            return const Text("No user data available");
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Wrap(
                    spacing: 30.0,
                    runSpacing: 30.0,
                    children: [
                      HomeWidget(
                        text: 'Health',
                        backgroundColor: Colors.red[300]!,
                        icon: Icons.favorite,
                        iconColor: Colors.pink,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MainPage(pageIndex: 1)));
                          print('Health Widget tapped!');
                        },
                      ),
                      HomeWidget(
                        text: 'Messages',
                        backgroundColor: Colors.blue[300]!,
                        icon: Icons.message,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MainPage(pageIndex: 2)));
                          print('Message Widget tapped!');
                        },
                      ),
                      HomeWidget(
                        text: 'Speech Visual',
                        backgroundColor: Colors.grey[500]!,
                        icon: Icons.mic,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SpeechScreen()));
                          print('Speech Widget tapped!');
                        },
                      ),
                      HomeWidget(
                        text: 'Location',
                        backgroundColor: Colors.green[300]!,
                        icon: Icons.map,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MainPage(pageIndex: 3)));
                          print('Map Widget tapped!');
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
