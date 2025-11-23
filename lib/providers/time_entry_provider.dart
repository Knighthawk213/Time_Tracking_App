import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:time_tracker/models/project.dart';
import 'package:time_tracker/models/task.dart';
import 'package:time_tracker/models/time_entry.dart';

class TimeEntryProvider extends ChangeNotifier{
  final LocalStorage storage = LocalStorage('time_tracker_app');

  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<TimeEntry> _timeEntries = [];

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;
  List<TimeEntry> get timeEntries => _timeEntries;

  //Initialize and load data from local storage
  Future<void> loadData() async{
    await storage.ready;

    //Load projects
    var projectsData = storage.getItem('projects');
    if (projectsData != null) {
      _projects = (jsonDecode(projectsData) as List)
          .map((item) => Project.fromJson(item))
          .toList();
    }

    // Load tasks
    var tasksData = storage.getItem('tasks');
    if (tasksData != null) {
      _tasks = (jsonDecode(tasksData) as List)
          .map((item) => Task.fromJson(item))
          .toList();
    }

    //Load time entries
    var entriesData = storage.getItem('timeEntries');
    if(entriesData != null){
      _timeEntries = (jsonDecode(entriesData) as List)
          .map((item) => TimeEntry.fromJson(item))
          .toList();
    }
    notifyListeners();
  }

  //Save data to local Storage
  Future<void> _saveData() async{
    await storage.setItem('projects',
        jsonEncode(_projects.map((p) => p.toJson()).toList()));
    await storage.setItem('tasks',
        jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    await storage.setItem('timeEntries',
        jsonEncode(_timeEntries.map((e) => e.toJson()).toList()));
  }

  // Add a new time entry
  void addTimeEntry(TimeEntry entry){
    _timeEntries.add(entry);
    _saveData();
    notifyListeners();
  }
  
  // Delete a time entry
  void deleteTimeEntry(String id){
    _timeEntries.removeWhere((entry) => entry.id == id);
    _saveData();
    notifyListeners();
  }
  
  // Add a new project
  void addProject(Project project){
    _projects.add(project);
    _saveData();
    notifyListeners();
  }
  
  //Delete a project
  void deleteProject(String id){
    _projects.removeWhere((project) => project.id == id);
    // Also delete assosciated tasks and time entries
    _tasks.removeWhere((task) => task.projectId == id);
    _timeEntries.removeWhere((entry) => entry.projectId == id);
    _saveData();
    notifyListeners();
  }

  //Add new task
  void addTask(Task task){
    _tasks.add(task);
    _saveData();
    notifyListeners();
  }

  //Delete a task
  void deleteTask(String id){
    _tasks.removeWhere((task) => task.id == id);
    //Also delete associated time entries
    _timeEntries.removeWhere((entry) => entry.taskId == id);
    _saveData();
    notifyListeners();
  }

  //Get tasks for a specific project
  Project? getProjectById(String id){
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch(e){
      return null;
    }
  }

  // Get total time for a project
  double getTotalTimeForProject(String projectId){
    return _timeEntries
        .where((entry) => entry.projectId == projectId)
        .fold(0.0, (sum, entry) => sum + entry.totalTime);
  }
}