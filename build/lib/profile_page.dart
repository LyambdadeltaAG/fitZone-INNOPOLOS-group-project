import 'package:fit/search_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart package
import '../main.dart'; // Ensure the path is correct

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> _results = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/results.json');
      if (await file.exists()) {
        final String response = await file.readAsString();
        final List<dynamic> data = json.decode(response);

        // Parse and sort data by date
        List<Map<String, dynamic>> parsedResults = data.map((result) => {
          'date': DateTime.parse(result['date']),
          'workout': result['workout'],
          'time': result['time'],
        }).toList();

        parsedResults.sort((a, b) => b['date'].compareTo(a['date']));

        setState(() {
          _results = parsedResults;
        });
      }
    } catch (e) {
      print('Error loading results: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredResults = _selectedDate == null
        ? _results
        : _results.where((result) {
      return DateFormat('yyyy-MM-dd').format(result['date']) ==
          DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }).toList();

    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: Icon(Icons.calendar_today, color: Colors.white,),
                    label: Text(
                      'Select Date',

                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF64B8B2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    _selectedDate == null
                        ? 'No Date Chosen'
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildPieChart(filteredResults.length),
            Expanded(
              child: filteredResults.isEmpty
                  ? Center(child: Text('No workout results found.'))
                  : ListView.builder(
                itemCount: filteredResults.length,
                itemBuilder: (context, index) {
                  final result = filteredResults[index];
                  return WorkoutCard(
                    workout: result['workout'],
                    date: result['date'],
                    time: result['time'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomMenu(),
    );
  }

  Widget _buildPieChart(int completedWorkouts) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.3,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 28,
              ),
              Text(
                'Completed Workouts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff37434d),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: _createPieChartSections(completedWorkouts),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,

                  ),
                ),
              ),
              const SizedBox(
                height: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(int completedWorkouts) {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: completedWorkouts.toDouble(),
        title: '$completedWorkouts',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.grey[300]!,
        value: (completedWorkouts == 0 ? 1 : 0).toDouble(),
        title: '',
        radius: 50,
      ),
    ];
  }
}

class WorkoutCard extends StatelessWidget {
  final String workout;
  final DateTime date;
  final String time;

  const WorkoutCard({
    required this.workout,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Color(0xFF64B8B2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(
          workout,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        subtitle: Text(
          'Date: $formattedDate\nTime: $time',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class BottomMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.0), bottom: Radius.circular(40.0)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.category_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_box_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
