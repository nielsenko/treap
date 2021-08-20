class Task implements Comparable<Task> {
  final int id;
  final String name;
  final DateTime due;
  final Duration duration;
  final bool completed;

  Task(this.id, this.name, this.due, this.duration, this.completed);

  @override
  int compareTo(Task other) {
    return id.compareTo(other.id);
  }

  Task copyWith({
    int? id,
    String? name,
    DateTime? due,
    Duration? duration,
    bool? completed,
  }) {
    return Task(
      id ?? this.id,
      name ?? this.name,
      due ?? this.due,
      duration ?? this.duration,
      completed ?? this.completed,
    );
  }
}
