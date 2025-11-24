import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_entry_provider.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  Project? _selectedProject;
  Task? _selectedTask;
  double _totalTime = 0.0;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Time Entry'),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.projects.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No projects available.\nPlease add a project first in settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Project Dropdown
                  DropdownButtonFormField<Project>(
                    decoration: const InputDecoration(
                      labelText: 'Project',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedProject,
                    items: provider.projects.map((project) {
                      return DropdownMenuItem(
                        value: project,
                        child: Text(project.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProject = value;
                        _selectedTask = null; // Reset task when project changes
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a project';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Task Dropdown
                  DropdownButtonFormField<Task>(
                    decoration: const InputDecoration(
                      labelText: 'Task',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTask,
                    items: _selectedProject != null
                        ? provider.getTasksForProject(_selectedProject!.id).map((task) {
                      return DropdownMenuItem(
                        value: task,
                        child: Text(task.name),
                      );
                    }).toList()
                        : [],
                    onChanged: (value) {
                      setState(() {
                        _selectedTask = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a task';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Total Time Input
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Total Time (hours)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 2.5',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter time';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Time must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notes Input
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Add any notes...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final timeEntry = TimeEntry(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          projectId: _selectedProject!.id,
                          taskId: _selectedTask!.id,
                          totalTime: double.parse(_timeController.text),
                          date: _selectedDate,
                          notes: _notesController.text,
                        );

                        provider.addTimeEntry(timeEntry);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Time entry added successfully!')),
                        );

                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('Save Time Entry', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}