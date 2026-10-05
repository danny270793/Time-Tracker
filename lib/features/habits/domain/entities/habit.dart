class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.completedDays,
    this.archivedAt,
  });

  final String id;
  final String name;
  final int color;
  final int icon;
  final Set<String> completedDays;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  Habit copyWith({
    String? id,
    String? name,
    int? color,
    int? icon,
    Set<String>? completedDays,
    DateTime? archivedAt,
    bool clearArchive = false,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      completedDays: completedDays ?? this.completedDays,
      archivedAt: clearArchive ? null : archivedAt ?? this.archivedAt,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'icon': icon,
    'completedDays': completedDays.toList()..sort(),
    'archivedAt': archivedAt?.toIso8601String(),
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as int,
      icon: json['icon'] as int,
      completedDays: (json['completedDays'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toSet(),
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
    );
  }
}

String dayKey(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
