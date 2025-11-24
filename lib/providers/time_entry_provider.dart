import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';

class TimeEntryProvider extends ChangeNotifier {
  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<TimeEntry> _timeEntries = [];

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;
  List<TimeEntry> get timeEntries => _timeEntries;

  // Initialize and load data from local storage
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load projects
    String? projectsData = prefs.getString('projects');
    if (projectsData != null) {
      _projects = (jsonDecode(projectsData) as List)
          .map((item) => Project.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Load tasks
    String? tasksData = prefs.getString('tasks');
    if (tasksData != null) {
      _tasks = (jsonDecode(tasksData) as List)
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Load time entries
    String? entriesData = prefs.getString('timeEntries');
    if (entriesData != null) {
      _timeEntries = (jsonDecode(entriesData) as List)
          .map((item) => TimeEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    notifyListeners();
  }

  // Save data to local storage
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('projects',
        jsonEncode(_projects.map((p) => p.toJson()).toList()));
    await prefs.setString('tasks',
        jsonEncode(_tasks.map((t) => t.toJson()).toList()));
    await prefs.setString('timeEntries',
        jsonEncode(_timeEntries.map((e) => e.toJson()).toList()));
  }

  // Add a new time entry
  void addTimeEntry(TimeEntry entry) {
    _timeEntries.add(entry);
    _saveData();
    notifyListeners();
  }

  // Delete a time entry
  void deleteTimeEntry(String id) {
    _timeEntries.removeWhere((entry) => entry.id == id);
    _saveData();
    notifyListeners();
  }

  // Add a new project
  void addProject(Project project) {
    _projects.add(project);
    _saveData();
    notifyListeners();
  }

  // Delete a project
  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    // Also delete associated tasks and time entries
    _tasks.removeWhere((task) => task.projectId == id);
    _timeEntries.removeWhere((entry) => entry.projectId == id);
    _saveData();
    notifyListeners();
  }

  // Add a new task
  void addTask(Task task) {
    _tasks.add(task);
    _saveData();
    notifyListeners();
  }

  // Delete a task
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    // Also delete associated time entries
    _timeEntries.removeWhere((entry) => entry.taskId == id);
    _saveData();
    notifyListeners();
  }

  // Get tasks for a specific project
  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  // Get project by ID
  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get task by ID
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get total time for a project
  double getTotalTimeForProject(String projectId) {
    return _timeEntries
        .where((entry) => entry.projectId == projectId)
        .fold(0.0, (sum, entry) => sum + entry.totalTime);
  }
}