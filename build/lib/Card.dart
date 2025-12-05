import 'dart:convert';
import 'dart:typed_data';

class MyCard {
  String title;
  String category;
  String duration;
  String difficulty;
  String timePerDay;
  String equipment;
  String description;
  List<String> images;

  MyCard({
    required this.title,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.timePerDay,
    required this.equipment,
    required this.description,
    required this.images,
  });

  factory MyCard.fromJson(Map<String, dynamic> json) {
    return MyCard(
      title: json['title'],
      category: json['category'],
      duration: json['duration'],
      difficulty: json['difficulty'],
      timePerDay: json['timePerDay'],
      equipment: json['equipment'],
      description: json['description'],
      images: List<String>.from(json['images']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'duration': duration,
      'timePerDay': timePerDay,
      'equipment': equipment,
      'difficulty': difficulty,
      'category': category,
    };
  }
}
