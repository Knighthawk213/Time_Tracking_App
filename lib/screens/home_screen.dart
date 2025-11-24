import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_entry_provider.dart';
import '../models/time_entry.dart';
import 'add_time_entry_screen.dart';
import 'project_task_management_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectTaskManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.timeEntries.isEmpty) {
            return const Center(
              child: Text(
                'No time entries yet.\nTap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Group time entries by project
          Map<String, List<TimeEntry>> groupedEntries = {};
          for (var entry in provider.timeEntries) {
            if (!groupedEntries.containsKey(entry.projectId)) {
              groupedEntries[entry.projectId] = [];
            }
            groupedEntries[entry.projectId]!.add(entry);
          }

          return ListView.builder(
            itemCount: groupedEntries.length,
            itemBuilder: (context, index) {
              String projectId = groupedEntries.keys.elementAt(index);
              List<TimeEntry> entries = groupedEntries[projectId]!;
              var project = provider.getProjectById(projectId);
              double totalTime = provider.getTotalTimeForProject(projectId);

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text(
                    project?.name ?? 'Unknown Project',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Total: ${totalTime.toStringAsFixed(2)} hours',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  children: entries.map((entry) {
                    var task = provider.getTaskById(entry.taskId);
                    return ListTile(
                      title: Text(task?.name ?? 'Unknown Task'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time: ${entry.totalTime.toStringAsFixed(2)} hours',
                          ),
                          Text(
                            'Date: ${DateFormat('MMM dd, yyyy').format(entry.date)}',
                          ),
                          if (entry.notes.isNotEmpty)
                            Text(
                              'Notes: ${entry.notes}',
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteDialog(context, provider, entry.id);
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTimeEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TimeEntryProvider provider, String entryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this time entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTimeEntry(entryId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Time entry deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}