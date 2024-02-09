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
  late int _selectedIndex = 0;

  final LocationTrackingService locationTrackingService =
      LocationTrackingService();

  @override
  void initState() {
    super.initState();
    locationTrackingService.startTracking();
    _selectedIndex = widget.pageIndex ?? 0; //default to 0
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const Healthpage(),
    const MessagePage(),
    const MapPage(),
  ];

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
      body: _pages[_selectedIndex],
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
