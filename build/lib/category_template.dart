import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:async'; // For timer
import 'package:confetti/confetti.dart'; // For confetti effect
import 'package:path_provider/path_provider.dart'; // For getting application directory
import 'dart:io'; // For file operations
import 'package:fit/Card.dart';
import 'package:fit/exercises_chain.dart';

class FitnessAppPage extends StatefulWidget {
  final String namePage;
  final List<String> categories;

  FitnessAppPage({required this.categories, required this.namePage});

  @override
  _FitnessAppPageState createState() => _FitnessAppPageState();
}

class _FitnessAppPageState extends State<FitnessAppPage> {
  List<MyCard> allWorkouts = [];
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories[0];
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    final String response = await rootBundle.loadString('assets/workouts.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      allWorkouts = data.map((json) => MyCard.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namePage),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: widget.categories.map((category) => _buildCategoryButton(category)).toList(),
            ),
          ),
          Expanded(
            child: _buildWorkoutPlans(_selectedCategory),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    bool isSelected = category == _selectedCategory;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF30A098) : Color(0xFFADBAB9),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            category,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutPlans(String category) {
    List<MyCard> plans = allWorkouts.where((workout) => workout.category == category).toList();

    return ListView.builder(
      itemCount: plans.length,
      itemBuilder: (context, index) {
        return _buildWorkoutPlan(plans[index]);
      },
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




class WorkoutDetailPage extends StatefulWidget {
  @override
  _WorkoutDetailPageState createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {



  @override
  Widget build(BuildContext context) {
    final MyCard workout = ModalRoute.of(context)!.settings.arguments as MyCard;
    final int workoutDuration = int.parse(workout.timePerDay.split('-')[0]) * 60;

    Widget _buildStartButton(){
      return
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            margin: EdgeInsets.only(bottom: 8.0),
            decoration: BoxDecoration(
              color: Color(0xFFC4C4C4),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExercisesChain(workout: workout),
                ),
              );
              },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "STAAAAAAART!!!",
                            style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),

                        ],
                      ),
                    ),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF9A8FBC),
                      ),
                      child:  Icon(Icons.play_arrow_outlined, color: Colors.white),

                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }

    Widget bodyCreator(){
      return SingleChildScrollView(
        padding: EdgeInsets.only(top: 16.0), // Add padding to the top
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //картинка
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 320,
                width: double.infinity,
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Opacity(
                        opacity: 0.6, // Устанавливаем прозрачность 60%
                        child: Image.asset(
                          'assets/cards/${workout.title}.jpg', // Убедитесь, что это изображение существует
                          fit: BoxFit.cover, // Заполняет все доступное пространство
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding( //описание
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Description:',
                style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold, color: Colors.deepPurple[200]),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0), // Reduced bottom padding here
              child: Text(
                '${workout.description}',
                style: TextStyle(fontSize: 21, color: Colors.deepPurple[200]), // Text color changed to purple
                textAlign: TextAlign.center,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Color(0xFF64B8B2) ,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Добавлено для выравнивания по левому краю
                  children: [
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:  25.0, vertical: 3),
                      child: Align(
                        alignment: Alignment.centerLeft, // Выравнивание по левому краю
                        child: Text(
                          'Duration: ${workout.duration}',
                          style: TextStyle(fontSize: 21, color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:  25.0, vertical: 3),
                      child: Align(
                        alignment: Alignment.centerLeft, // Выравнивание по левому краю
                        child: Text(
                          'Time per day: ${workout.timePerDay}',
                          style: TextStyle(fontSize: 21, color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:  25.0, vertical: 3),
                      child: Align(
                        alignment: Alignment.centerLeft, // Выравнивание по левому краю
                        child: Text(
                          'Equipment: ${workout.equipment}',
                          style: TextStyle(fontSize: 21, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
            ),



          ],
        ),
      );
    }


    return  Scaffold(
        bottomNavigationBar: _buildStartButton(),
        appBar: AppBar(
          title: Text(workout.title.replaceAll('_', ' ')),
        ),
        body: bodyCreator(),

    );
  }
}



