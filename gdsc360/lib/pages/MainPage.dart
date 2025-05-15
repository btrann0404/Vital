import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc360/components/SpeechButton.dart';
import 'package:gdsc360/pages/HealthPage.dart';
import 'package:gdsc360/pages/HomePage.dart';
import 'package:gdsc360/pages/MapPage.dart';
import 'package:gdsc360/pages/MessagePage.dart';
import 'package:gdsc360/pages/Signup.dart';
import 'package:gdsc360/components/SlideBar.dart';
import 'package:gdsc360/pages/Speech.dart';
import 'package:gdsc360/utils/authservice.dart';
import 'package:gdsc360/utils/locationservice.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  final int? pageIndex;
  const MainPage({Key? key, this.pageIndex}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Auth _auth = Auth();
  late int _selectedIndex = 0;

  final LocationTrackingService locationTrackingService =
      LocationTrackingService();

  get _pages => _getPages();

  @override
  void initState() {
    super.initState();
    if (!locationTrackingService.isTracking) {
      locationTrackingService.startTracking();
    }
    _selectedIndex = widget.pageIndex ?? 0; //default to 0
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddPartnerDialog() {
    final TextEditingController _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Your Partner'),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(hintText: "Partner's Email"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                print('Partner email: ${_emailController.text}');
                String partnerEmail = _emailController.text;
                //messes up the app for some reasons cause of mount of smt???
                // Navigator.of(context).pop();

                if (!mounted) return;

                // i should probably move this
                var partnerDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: partnerEmail)
                    .get();

                if (partnerDoc.docs.isNotEmpty) {
                  var partnerData = partnerDoc.docs.first.data();
                  var partnerID = partnerDoc.docs.first.id;
                  var partnerRole = partnerData['role'];
                  var partnerHasPartner = partnerData['partnerID'] != null;

                  // Fetch current user's data
                  var currentUser = FirebaseAuth.instance.currentUser;
                  var currentUserDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser!.uid)
                      .get();
                  var currentUserData = currentUserDoc.data();
                  var currentUserRole = currentUserData!['role'];
                  var currentUserHasPartner =
                      currentUserData['partnerID'] != null;

                  if (!partnerHasPartner &&
                      !currentUserHasPartner &&
                      partnerRole != currentUserRole) {
                    // Update both users to set each other as partners
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .update({'partnerID': partnerID});
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(partnerID)
                        .update({'partnerID': currentUser.uid});

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainPage(pageIndex: 0)));

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Partner added successfully.")));
                  } else {
                    // Conditions not met, show an error message
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("Cannot add partner. Check conditions.")));
                  }
                } else {
                  // Partner email not found, show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Partner email not found.")));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Widget>> _getPages() async {
    String currUserID = _auth.getCurrentUserUid().toString();
    Map<String, dynamic>? currentUserInfo = await _auth.getUserData(currUserID);

    // Check if the currentUserInfo contains a partnerID
    bool hasPartner =
        currentUserInfo != null && currentUserInfo["partnerID"] != null;

    // If there is no partnerID, return a list of widgets that show an error/prompt for adding a partner
    if (!hasPartner) {
      // This widget will be shown in place of all other pages when there's no partnerID
      Widget errorPage = Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('No partner set. Please add a partner to use this feature.'),
              ElevatedButton(
                onPressed: () {
                  _showAddPartnerDialog();
                },
                child: Text('Add Partner'),
              ),
            ],
          ),
        ),
      );

      // Return the errorPage for all your app's main navigation points
      return List<Widget>.filled(4, errorPage, growable: false);
    }

    // If there is a partnerID, return the list of pages as normal
    return [
      const HomePage(),
      const Healthpage(),
      MessagePage(),
      const MapPage(),
    ];
  }

  final List<String> _pagetitles = [
    "Home Dashboard",
    "Health Dashboard",
    "Message Dashboard",
    "Partner's Location",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pagetitles[_selectedIndex]),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 142, 217, 252),
        leading: Builder(
          // Wrap with Builder to get the correct context
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.black,
                  size: 36,
                ),
              ),
            );
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {
              print("Emergency Icon Tapped");
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(right: 16),
              child: const Icon(
                Icons.emergency,
                color: Colors.red,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      drawer: SlideBar(),
      body: FutureBuilder<List<Widget>>(
        future:
            _getPages(), // Assuming this is your method that returns Future<List<Widget>>
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Now you can safely access the pages
            return snapshot.data![
                _selectedIndex]; // Use the index to access the correct page
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _selectedIndex !=
              2 // Assuming 'Messages' is at index 2
          ? Padding(
              padding: const EdgeInsets.only(
                  bottom: 80.0), // Adjust the padding as needed
              child: SpeechButton(),
            )
          : null, // Don't display the button when the 'Messages' tab is selected
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 142, 217, 252),
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital), label: "Health"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Location"),
        ],
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.black,
        selectedFontSize: 12,
        unselectedFontSize: 12,
      ),
    );
  }
}
