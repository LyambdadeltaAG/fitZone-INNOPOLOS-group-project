import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:fit/profile_page.dart';
import 'main.dart';
import 'package:fit/Card.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<MyCard> allWorkouts = [];
  List<MyCard> searchResults = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadWorkoutData() async {
    final String response = await rootBundle.loadString('assets/workouts.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      allWorkouts = data.map((json) => MyCard.fromJson(json)).toList();
    });
  }

  void _onSearchChanged() {
    setState(() {
      searchResults = allWorkouts
          .where((workout) => workout.title.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Поиск'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Введите название тренировки',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: searchResults.isEmpty
                ? Center(child: Text('Нет результатов'))
                : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return _buildWorkoutPlan(searchResults[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomMenu(),
    );
  }

  Widget _buildWorkoutPlan(MyCard workout) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF64B8B2),
          border: Border.all(color: Color(0xFF64B8B2)!),
          borderRadius: BorderRadius.circular(35.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                flex: 2,
                child: Padding(

                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      //сложность выбранного воркаута
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),


                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if(workout.difficulty == "1") ...[
                              drawCircular(Color(0xFF22DB6C)),
                            ]
                            else if(workout.difficulty == "2") ...[
                              drawCircular(Color(0xFFF0D164)),
                              SizedBox(width: 10,),
                              drawCircular(Color(0xFFF0D164)),
                            ]
                            else ...[
                                drawCircular(Color(0xFFCC2525)),
                                SizedBox(width: 10,),
                                drawCircular(Color(0xFFCC2525)),
                                SizedBox(width: 10,),
                                drawCircular(Color(0xFFCC2525)),
                              ]
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [

                          Container(
                            height: 200,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        // Прозрачность фона контейнера
                                      ),
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(30),
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              Colors.black.withOpacity(0.6), // Прозрачность изображения
                                              BlendMode.dstATop,
                                            ),
                                            child: Image.asset(
                                              'assets/cards/${workout.title}.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  workout.title.replaceAll('_', ' '),
                                  style: TextStyle(
                                      color: Colors.white,
                                      //fontWeight: FontWeight.bold,
                                      fontSize: 22
                                  ),

                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

              ),

              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF9A8FBC),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Days: ${workout.duration}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10.0), // отступ между "Days" и "Time"
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF9A8FBC),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '${workout.timePerDay}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10.0), // отступ под "Time"
                        Text(
                          'Equipment: ${workout.equipment}',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10.0), // отступ перед кнопкой
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF9A8FBC),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.play_arrow_outlined, color: Colors.white),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/details',
                                arguments: workout,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //рисует круги для сложности
  Widget drawCircular(Color difficultyColor){
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: difficultyColor,
        shape: BoxShape.circle,
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
