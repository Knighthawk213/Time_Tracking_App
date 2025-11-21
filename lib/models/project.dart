import 'package:flutter/cupertino.dart';

class Project {
  final String id;
  final String name;

  Project({
    required this.id,
    required this.name,
  });

  // Convert Project to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Create Project from JSON (when reading from local storage)
  factory Project.fromJson(Map<String, dynamic> json){
    return Project(
        id: json['id'],
        name: json['name'],
    );
  }
}