// Основной файл

import 'package:flutter/material.dart';
import '/category_template.dart'; // Импорт вашего шаблона страницы
import 'search_page.dart'; // Импорт вашей страницы поиска
import 'profile_page.dart'; // Импорт вашей страницы профиля

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      routes: {
        '/details': (context) => WorkoutDetailPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomMenu(),
      body: SafeArea(
        child:
             Center(
               child: ListView.builder(
                  itemCount: 3, // Фиксированное количество элементов
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 150, // Задаем фиксированную высоту контейнера
                      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFF64B8B2),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: OptionTile(
                          title: index == 0
                              ? 'Maintain shape/ get fit'
                              : index == 1
                              ? 'Rehabilitation'
                              : 'Physeotherapy',
                          imageAsset: index == 0
                              ? 'assets/fit.png'
                              : index == 1
                              ? 'assets/rehab.png'
                              : 'assets/physio.png',
                          nextPage: FitnessAppPage(
                            categories: index == 0
                                ? ['body', 'legs', 'arms']
                                : index == 1
                                ? ['body-lfk', 'legs-lfk', 'arms-lfk']
                                : ['body-phys', 'legs-phys', 'arms-phys'],
                            namePage: index == 0
                                ? 'Maintain shape/ get fit'
                                : index == 1
                                ? 'Rehabilitation'
                                : 'Physeotherapy',
                          ),
                        ),
                      ),
                    );
                  },
                ),
             ),




      ),
    );
  }
}

class OptionTile extends StatelessWidget {
  final String title;
  final String imageAsset;
  final Widget nextPage;

  const OptionTile({
    required this.title,
    required this.imageAsset,
    required this.nextPage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      child: Container(
        child: Center(
          child: ListTile(
            contentPadding: EdgeInsets.all(15.0),
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(imageAsset),
              radius: 30,

            ),
            title: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  title,

                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ),
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

