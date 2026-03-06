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
    'completedAt': completedAt.toUtc().toIso8601String(),
  };

  factory Moment.fromJson(Map<String, dynamic> json) {
    final raw = json['completedAt'] as String;
    final parsed = DateTime.parse(raw);
    // New data ends with 'Z' (UTC). Old data has no offset → parsed as local.
    // Normalize everything to UTC.
    final utc = parsed.isUtc ? parsed : parsed.toUtc();

    return Moment(
      id: json['id'] as String,
      habitName: json['habitName'] as String,
      habitEmoji: json['habitEmoji'] as String,
      completedAt: utc,
    );
  }
}