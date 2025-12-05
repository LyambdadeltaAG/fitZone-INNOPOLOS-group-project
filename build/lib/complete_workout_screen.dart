import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:async'; // For timer
import 'package:confetti/confetti.dart'; // For confetti effect
import 'package:path_provider/path_provider.dart'; // For getting application directory
import 'dart:io'; // For file operations
import 'package:fit/Card.dart';
import 'package:fit/profile_page.dart';

class CompleteWorkoutScreen extends StatefulWidget {
  //final Timer fullTimer;
  final MyCard workout;
  const CompleteWorkoutScreen({required this.workout});

  @override
  _CompleteWorkoutScreen createState() => _CompleteWorkoutScreen();

}
class _CompleteWorkoutScreen extends State<CompleteWorkoutScreen> with TickerProviderStateMixin {
  //late Timer fullTimer = widget.fullTimer;
  late final MyCard workout = widget.workout;
  bool isCompleted = false;
  late AnimationController _controller;
  late Animation<double> _imageAnimation;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _descriptionTitleAnimation;
  late Animation<double>  _extraInformationAnimation;
  late Animation<double> _opacityAnimation;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    // Анимация для изображения
    _imageAnimation = Tween<double>(
      begin: 1000.0, // Начальная позиция по оси Y (выше экрана)
      end: 0.0, // Конечная позиция по оси Y (внизу экрана)
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeInOut), // Начало анимации (0%) и конец (60%)
      ),
    );

    // Анимация для описания
    _descriptionAnimation = Tween<double>(
      begin: 2000.0, // Начальная позиция по оси Y (выше экрана)
      end: 0.0, // Конечная позиция по оси Y (внизу экрана)
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1.0, curve: Curves.easeInOut), // Начало анимации (40%) и конец (100%)
      ),
    );
    _descriptionTitleAnimation = Tween<double>(
      begin: 2500.0, // Начальная позиция по оси Y (выше экрана)
      end: 0.0, // Конечная позиция по оси Y (внизу экрана)
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1.0, curve: Curves.easeInOut), // Начало анимации (40%) и конец (100%)
      ),
    );
    _extraInformationAnimation = Tween<double>(
      begin: 3200.0, // Начальная позиция по оси Y (выше экрана)
      end: 0.0, // Конечная позиция по оси Y (внизу экрана)
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 1.0, curve: Curves.easeInOut), // Начало анимации (40%) и конец (100%)
      ),
    );

    // Анимация прозрачности
    _opacityAnimation = Tween<double>(
      begin: 0.0, // Начальная прозрачность (полностью прозрачно)
      end: 1.0, // Конечная прозрачность (полностью видимо)
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut), // Начало анимации (0%) и конец (100%)
      ),
    );

    // Запуск анимации
    _controller.forward();
  }

  Widget _buildCompleteButton(){
    return
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Container(
          margin: EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color:  Color(0xFF64B8B2),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                Navigator.push( //передаем на новый экран информацию о таймере
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              });

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
                          "To statistics",
                          style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget bodyCreator() {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 16.0), // Add padding to the top
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'Workout complete!',
                  style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold, color: Colors.deepPurple[200]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Отображаемое изображение
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0.0, _imageAnimation.value), // Перемещаем виджет по вертикали
                  child: Opacity(
                    opacity: _opacityAnimation.value, // Применяем анимацию прозрачности
                    child: child,
                  ),
                );
              },
              child: Padding(
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
                            'assets/cards/${widget.workout.title}.jpg', // Убедитесь, что это изображение существует
                            fit: BoxFit.cover, // Заполняет все доступное пространство
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Описание
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0.0, _descriptionTitleAnimation.value), // Перемещаем виджет по вертикали
                  child: Opacity(
                    opacity: _opacityAnimation.value, // Применяем анимацию прозрачности
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Description:',
                  style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold, color: Colors.deepPurple[200]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Текст описания
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0.0, _descriptionAnimation.value), // Перемещаем виджет по вертикали
                  child: Opacity(
                    opacity: _opacityAnimation.value, // Применяем анимацию прозрачности
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0), // Reduced bottom padding here
                      child: Text(
                        '${widget.workout.description}',
                        style: TextStyle(fontSize: 21, color: Colors.deepPurple[200]), // Text color changed to purple
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Дополнительная информация
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0.0, _extraInformationAnimation.value), // Перемещаем виджет по вертикали
                  child: Opacity(
                    opacity: _opacityAnimation.value, // Применяем анимацию прозрачности
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xFFC4C4C4),
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
                                  'Duration: ${widget.workout.duration}',
                                  style: TextStyle(fontSize: 21, color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal:  25.0, vertical: 3),
                              child: Align(
                                alignment: Alignment.centerLeft, // Выравнивание по левому краю
                                child: Text(
                                  'Time per day: ${widget.workout.timePerDay}',
                                  style: TextStyle(fontSize: 21, color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal:  25.0, vertical: 3),
                              child: Align(
                                alignment: Alignment.centerLeft, // Выравнивание по левому краю
                                child: Text(
                                  'Equipment: ${widget.workout.equipment}',
                                  style: TextStyle(fontSize: 21, color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildCompleteButton(),
      body: bodyCreator(),

    );
  }
}