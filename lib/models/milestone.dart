class Milestone {
  final String id;                 // simple string id
  final String name;               // e.g., Birthday, Anniversary
  final DateTime date;             // original date (year used only for custom)
  final bool repeatYearly;         // birthdays/anniversaries: true

  Milestone({
    required this.id,
    required this.name,
    required this.date,
    this.repeatYearly = true,
  });

  /// Next occurrence from 'now' (for yearly milestones).
  DateTime nextOccurrence([DateTime? from]) {
    final now = (from ?? DateTime.now());
    if (!repeatYearly) return date;
    final sameYear = DateTime(now.year, date.month, date.day);
    return (sameYear.isBefore(DateTime(now.year, now.month, now.day)))
        ? DateTime(now.year + 1, date.month, date.day)
        : sameYear;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'repeatYearly': repeatYearly,
      };

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
        id: json['id'] as String,
        name: json['name'] as String,
        date: DateTime.parse(json['date'] as String),
        repeatYearly: (json['repeatYearly'] as bool?) ?? true,
      );
}
