import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:async'; // For timer
import 'package:confetti/confetti.dart'; // For confetti effect
import 'package:path_provider/path_provider.dart'; // For getting application directory
import 'dart:io'; // For file operations
import 'package:fit/Card.dart';
import 'package:fit/complete_workout_screen.dart';

class ExercisesChain extends StatefulWidget {
  final MyCard workout;

  ExercisesChain({required this.workout});

  @override
  _ExercisesChain createState() => _ExercisesChain();
}

class _ExercisesChain extends State<ExercisesChain> with TickerProviderStateMixin {
  late MyCard  workout = widget.workout;
  //late MyCard workout = ModalRoute.of(context)!.settings.arguments as MyCard;
  late List<String> images = workout.images;
  late int workoutDuration = int.parse(workout.timePerDay.split('-')[0]) * 60;
  late int amountOfWorkouts = workout.images.length;



  //это контроллеры перехода и полоски
  late AnimationController _progressController;
  late AnimationController _transitionController; // Контроллер анимации перехода
  double _progress = 0.0; // Прогресс для движущейся полоски
  bool isPlaying = true;
  bool isDescriptionOpened = false;

  //параметры упражнений

  late int exersiceCounter = 0;//начинается счетчик упражнений всегда с 0
  late int _countdownSeconds = 10;//время одного упражнения  в сек

  bool forwardPressed = false;
  bool previousPressed = false;

  late Timer _timer; // Таймер для обновления счетчика
  late DateTime _startTime;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _countdownSeconds),
    );
    _progressController.addListener(() {
      setState(() {
        _progress = _progressController.value;
      });
    });
    _progressController.forward();
    _startTimer();
    _startFullTimer();
    // Инициализация контроллера анимации перехода
    _transitionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    // Обнуляем значение анимации перехода
    _transitionController.value = 0.0;
    // При первой загрузке виджета запускаем анимацию перехода
    _transitionController.forward();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }


  @override
  void dispose() {
    //_fullTimer.cancel();
    _confettiController.dispose();
    _timer.cancel();
    _progressController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _startFullTimer() {
    _startTime = DateTime.now();

  }


  Future<void> _completeWorkout(MyCard workout) async {

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);

    final Duration elapsed = now.difference(_startTime);
    final int elapsedMinutes = elapsed.inMinutes;
    final int elapsedSeconds = elapsed.inSeconds % 60;

    final Map<String, String> result = {
      'date': formatted,
      'workout': workout.title,
      'time': '$elapsedMinutes min ${elapsedSeconds.toString().padLeft(2, '0')} sec',
    };

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/results.json');

    List<dynamic> results = [];
    if (await file.exists()) {
      final String response = await file.readAsString();
      results = json.decode(response);
    }

    results.add(result);
    final String updatedResults = json.encode(results);
    await file.writeAsString(updatedResults);

  }

  void _startTimer() {

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          // Увеличиваем exersiceCounter и обновляем таймер
          if (_countdownSeconds == 0 && exersiceCounter < workout.images.length - 1) {
            exersiceCounter++;
            // Анимация перехода запускается только при смене упражнения
            _transitionController.forward(from: 0.0);
            _updateTimer(); // Обновляем таймер для следующего упражнения
          } else {
            _timer.cancel(); // Останавливаем таймер при достижении конца списка упражнений
            Navigator.push( //передаем на новый экран информацию о таймере
              context,
              MaterialPageRoute(
                builder: (context) => CompleteWorkoutScreen( workout: workout),
              ),
            );
          }
        }
      });
    });
  }

  void _pauseTimer() {
    _timer.cancel();

    _progressController.stop();
  }

  void _resumeTimer() {
    _startTimer();

    _progressController.forward();
  }

  void _updateTimer() {
    // Остановить предыдущий таймер, если он был запущен
    _timer.cancel();
    // Получаем новое значение времени из списка упражнений для текущего дня
    _countdownSeconds = 10;
    // Обновляем длительность анимации прогресса
    _progressController.duration = Duration(seconds: _countdownSeconds);

    // Сбрасываем и запускаем анимацию прогресса
    _progressController.reset();
    _progressController.forward();

    // Запускаем новый таймер
    _startTimer();
    if(forwardPressed) _transitionController.forward(from: 0.0);
    if(previousPressed)  _transitionController.forward(from: 0.0);

  }

  @override
  Widget build(BuildContext context) {
    //final MyCard workout = ModalRoute.of(context)!.settings.arguments as MyCard;
    //final int workoutDuration = int.parse(workout.timePerDay.split('-')[0]) * 60;
    final List<String> images = workout.images;

    Widget player(){
      return  Container(

        padding: EdgeInsets.symmetric(horizontal: 55.0, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.fast_rewind, size: 40, color: Colors.deepPurple,),
              onPressed: () {
                setState(() {
                  // Переключаемся на предыдущий день (если возможно)
                  if (exersiceCounter > 0) {
                    isDescriptionOpened  = false;
                    exersiceCounter--;
                    previousPressed = true;
                    _updateTimer();
                    previousPressed = false;
                  }
                });

              },
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,size: 40, color: Colors.deepPurple,),
              onPressed: () {
                setState(() {
                  isPlaying = !isPlaying;
                  if (isPlaying) {
                    _resumeTimer(); // Возобновляем таймер и анимацию
                  } else {
                    _pauseTimer(); // Останавливаем таймер и анимацию
                  }

                });
              },
            ),
            IconButton(
              icon: Icon(Icons.fast_forward,size: 40, color: Colors.deepPurple,),
              onPressed: () {
                setState(() {
                  // Переключаемся на следующий день (если возможно)
                  if (exersiceCounter < workout.images.length - 1) {
                    isDescriptionOpened  = false;
                    exersiceCounter++;
                    forwardPressed = true;
                    _updateTimer();
                    forwardPressed = false;

                  }
                  else{
                    _timer.cancel(); // Останавливаем таймер при достижении конца списка упражнений
                    _completeWorkout(workout);
                    Navigator.push( //передаем на новый экран информацию о таймере
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompleteWorkoutScreen(workout: workout),
                      ),
                    );
                  }
                });

              },
            ),
          ],
        ),
      );
    }

    Widget bodyCreator() {
      return AnimatedBuilder(
        animation: _transitionController,
        builder: (context, child) {
          return Opacity(
            opacity: _transitionController.value, // Применяем текущее значение анимации к прозрачности
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(1.0, 0.0), // Начальное положение (с права)
                end: Offset.zero, // Конечное положение (центр)
              ).animate(_transitionController),
              child: child,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                workout.title,
                style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[200],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            //gif
            Expanded(
              flex:2,
              child: Image.asset(
                images[exersiceCounter], // путь к вашему GIF-файлу
                //fit: BoxFit.cover, // покройте все доступное пространство
              ),
            ),
            //time
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '$_countdownSeconds',
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[200],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            //time line             padding: const EdgeInsets.only(left: 35.0, right: 35.0,bottom: 8.0),
            Padding(
              padding:const EdgeInsets.only(left: 35.0, right: 35.0,bottom: 8.0),
              child: Stack(
                children: [
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,

                    ),
                  ),
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Colors.purple, Colors.green],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //time whole remain
            Padding(
              padding: const EdgeInsets.only(left: 35.0),
              child: Text(
                "Exersises remained: " + (amountOfWorkouts- exersiceCounter-1).toString(),
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: exersiceCounter<=workout.images.length-3 ? Colors.deepPurple[200]: Color(0xFF64B8B2),
                ),

              ),
            ),

            //description

            Padding(
              padding: const EdgeInsets.only(left: 35.0),
              child: Row(
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[200],
                    ),
                  ),
                  IconButton(
                    icon: Icon(isDescriptionOpened ?Icons.keyboard_arrow_up_rounded: Icons.keyboard_arrow_down_rounded, size: 25, color: Colors.deepPurple,),
                    onPressed: () {
                      isDescriptionOpened =!isDescriptionOpened ;// Add functionality for back button
                    },
                  ),
                ],
              ),
            ),

            //Expanded description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: AnimatedOpacity(
                    opacity: isDescriptionOpened ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        workout.description,
                        style: TextStyle(
                          fontSize: 21.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[200],
                        ),

                      ),

                    ),
                  ),
                ),
              ),
            ),
            //здесь плеер
          player()

          ],
        ),
      );
    }


    return Scaffold(
        //bottomNavigationBar: player() ,
        appBar: AppBar(
          title: Text(workout.title.replaceAll('_', ' ')),
        ),
        body: bodyCreator(),

    );
  }
}