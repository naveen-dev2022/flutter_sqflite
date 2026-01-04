class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final String mood;
  final DateTime date;
  final DateTime updatedAt;
  final bool isFavorite;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.date,
    required this.updatedAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'date': date.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      mood: map['mood'],
      date: DateTime.parse(map['date']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.parse(map['date']),
      isFavorite: map['is_favorite'] == 1,
    );
  }

  DiaryEntry copyWith({
    int? id,
    String? title,
    String? content,
    String? mood,
    DateTime? date,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      date: date ?? this.date,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
