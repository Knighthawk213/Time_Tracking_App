class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final double totalTime; // in hours
  final DateTime date;
  final String notes;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.totalTime,
    required this.date,
    required this.notes,
  });

  // Convert TimeEntry to JSON
  Map<String,dynamic> toJson(){
    return{
      'id' : id,
      'projectId' : projectId,
      'taskId' : taskId,
      'totalTime' : totalTime,
      'date' : date.toIso8601String(),
      'notes' : notes,
    };
  }

  // Create TimeEntry from JSON
  factory TimeEntry.fromJson(Map<String, dynamic>json){
    return TimeEntry(
        id: json['name'],
        projectId: json['projectId'],
        taskId: json['taskId'],
        totalTime: json['totalTime'],
        date: DateTime.parse(json['date']),
        notes: json['notes'],
    );
  }
}