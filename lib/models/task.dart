import 'dart:ffi';

class Task {
  final String id;
  final String name;
  final String projectId;

  Task({
    required this.id,
    required this.name,
    required this.projectId,
  });

  // Convert Task to JSON
  Map<String,dynamic> toJson(){
    return{
      'id' : id,
      'name' : name,
      'projectId' : projectId,
    };
  }

  //Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json){
    return Task(
        id: json['id'],
        name: json['name'],
        projectId: json['projectId'],
    );
  }
}