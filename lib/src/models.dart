class Task {
  final Map<String, dynamic> duration;
  final date;
  Task({required this.duration, required this.date});

  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      duration: data['duration'],
      date: data["date"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'duration': {
        'hours': duration['hours'],
        'minutes': duration['minutes'],
      },
    };
  }
}
