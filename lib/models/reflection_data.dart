class ReflectionData {
  final int daysActive;
  final int totalDays;
  final String? topFocusArea;
  final String? secondFocusArea;
  final String? bestDay;
  final String? secondBestDay;
  final int refreshCount;
  final int swapCount;
  final bool hasPatternData;
  final bool isComeback;
  final String weekRange;
  final String? validUntil; // ISO 8601 date-time, end of Sunday
  final List<bool>? dailyActivity; // 7 booleans, Mon–Sun
  final List<String>? completedHabits; // habit names sorted by count desc

  const ReflectionData({
    required this.daysActive,
    this.totalDays = 7,
    this.topFocusArea,
    this.secondFocusArea,
    this.bestDay,
    this.secondBestDay,
    required this.refreshCount,
    required this.swapCount,
    required this.hasPatternData,
    required this.isComeback,
    required this.weekRange,
    this.validUntil,
    this.dailyActivity,
    this.completedHabits,
  });

  Map<String, dynamic> toJson() => {
        'daysActive': daysActive,
        'totalDays': totalDays,
        'topFocusArea': topFocusArea,
        'secondFocusArea': secondFocusArea,
        'bestDay': bestDay,
        'secondBestDay': secondBestDay,
        'refreshCount': refreshCount,
        'swapCount': swapCount,
        'hasPatternData': hasPatternData,
        'isComeback': isComeback,
        'weekRange': weekRange,
        'validUntil': validUntil,
        'dailyActivity': dailyActivity,
        'completedHabits': completedHabits,
      };

  factory ReflectionData.fromJson(Map<String, dynamic> json) => ReflectionData(
        daysActive: json['daysActive'] as int,
        totalDays: json['totalDays'] as int? ?? 7,
        topFocusArea: json['topFocusArea'] as String?,
        secondFocusArea: json['secondFocusArea'] as String?,
        bestDay: json['bestDay'] as String?,
        secondBestDay: json['secondBestDay'] as String?,
        refreshCount: json['refreshCount'] as int,
        swapCount: json['swapCount'] as int,
        hasPatternData: json['hasPatternData'] as bool,
        isComeback: json['isComeback'] as bool,
        weekRange: json['weekRange'] as String,
        validUntil: json['validUntil'] as String?,
        dailyActivity: (json['dailyActivity'] as List?)
            ?.map((e) => e as bool)
            .toList(),
        completedHabits: (json['completedHabits'] as List?)
            ?.map((e) => e as String)
            .toList(),
      );
}
