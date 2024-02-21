import 'package:flutter/material.dart';
import 'package:gdsc360/components/health_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Healthpage extends StatefulWidget {
  const Healthpage({Key? key}) : super(key: key);

  @override
  _HealthpageState createState() => _HealthpageState();
}

class _HealthpageState extends State<Healthpage> {
  String recommendation = 'Loading suggestion...';
  String heartRate = 'Fetching Data!';
  String steps = 'Fetching Data!';
  String hoursOfSleep = 'Fetching Data!';
  bool isChartMode = false; // Add a boolean flag for toggling chart mode

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/data'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        recommendation = data['recommendation'];
        heartRate = data['heart_rate'];
        steps = data['steps'];
        hoursOfSleep = data['hours_of_sleep'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: isChartMode ? _buildChartPage() : _buildHealthPage(),
    );
  }

  Widget _buildHealthPage() {
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: HealthCard(
                icon: Icons.lightbulb_circle,
                title: "Your Recommendation",
                subtitle: recommendation,
                iconColor: Color.fromARGB(255, 112, 108, 76),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: HealthCard(
                icon: Icons.favorite,
                title: "Heart Rate",
                subtitle: "Current heart rate: $heartRate beats/minute.\nHealthy Range: 60 bpm - 100 bpm",
                iconColor: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: HealthCard(
                icon: Icons.timeline,
                title: "Blood Sugar",
                subtitle: "Current blood sugar: 90 mg/dL\nHealthy Range: 70 mg/dL - 100 mg/dL",
                iconColor: Colors.pink,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: HealthCard(
                icon: Icons.directions_walk,
                title: "Steps",
                subtitle: "Current steps taken: $steps\nHealthy Range: 10,000 steps",
                iconColor: Colors.blue,
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isChartMode = true;
                  });
                },
                child: Text('View Charts'),
              ),
            ),
          ],
        ),
      ],
    );
  }



Widget _buildChartPage() {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('lib/assets/heartrate.png'),
              Image.asset('lib/assets/bloodsugar.png'),
              Image.asset('lib/assets/steps_chart.png'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isChartMode = false;
                  });
                },
                child: Text('Back To Health'),

              ),
              const SizedBox(height: 60,)
            ],
          ),
        ),
      ),
    ),
  );
}
}

