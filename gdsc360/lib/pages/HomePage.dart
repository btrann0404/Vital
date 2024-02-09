import 'package:flutter/material.dart';
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
      final response = await http.get(Uri.parse('http://0000:8000/'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Error: Server responded with status code ${response.statusCode}";
      }
    } catch (e) {
      // print(e);
      // return "Error: No Response From Server";
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                FutureBuilder<String>(
                                  future: fetchData(),
                                  builder: (context, asyncSnapshot) {
                                    if (asyncSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (asyncSnapshot.hasError) {
                                      return Text(
                                          "Error: ${asyncSnapshot.error}");
                                    } else if (asyncSnapshot.hasData) {
                                      return Text(asyncSnapshot.data!);
                                    } else {
                                      return const Text("No data from server");
                                    }
                                  },
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
                // Additional Widgets can be added here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
