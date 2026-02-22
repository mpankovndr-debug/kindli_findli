class Moment {
  final String id;
  final String habitName;
  final String habitEmoji;
  final DateTime completedAt;

  const Moment({
    required this.id,
    required this.habitName,
    required this.habitEmoji,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitName': habitName,
    'habitEmoji': habitEmoji,
    'completedAt': completedAt.toIso8601String(),
  };

  factory Moment.fromJson(Map<String, dynamic> json) => Moment(
    id: json['id'] as String,
    habitName: json['habitName'] as String,
    habitEmoji: json['habitEmoji'] as String,
    completedAt: DateTime.parse(json['completedAt'] as String),
  );
}