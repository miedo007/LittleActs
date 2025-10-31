class WeeklyGesture {
  final String id;              // unique id (e.g., "2025-W44")
  final String title;           // the action
  final String category;        // service / time / gift / touch / words
  final DateTime weekStart;     // start of the week (Sun at 00:00)
  final bool completed;
  final DateTime? completedAt;

  WeeklyGesture({
    required this.id,
    required this.title,
    required this.category,
    required this.weekStart,
    this.completed = false,
    this.completedAt,
  });

  WeeklyGesture copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? weekStart,
    bool? completed,
    DateTime? completedAt,
  }) {
    return WeeklyGesture(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      weekStart: weekStart ?? this.weekStart,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'weekStart': weekStart.toIso8601String(),
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory WeeklyGesture.fromJson(Map<String, dynamic> json) => WeeklyGesture(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        weekStart: DateTime.parse(json['weekStart'] as String),
        completed: (json['completed'] as bool?) ?? false,
        completedAt: (json['completedAt'] as String?) != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );
}
