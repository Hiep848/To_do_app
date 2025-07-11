class ToDo {
  final String id;
  final String title;
  final String description;
  final DateTime lastModify;
  bool isCompleted;

  ToDo({
    required this.id,
    required this.title,
    required this.description,
    required this.lastModify,
    this.isCompleted = false,
  });

  ToDo copyWith({
    String? id,
    String? description,
    bool? isCompleted,
    String? title,
    DateTime? lastModify,
  }) {
    return ToDo(
      id: id ?? this.id,
      title: title ?? this.title,
      lastModify: lastModify ?? this.lastModify,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'ToDo{id: $id, title: $title, description: $description, lastModify: $lastModify, isCompleted: $isCompleted}';
  }

  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;

    return other is ToDo &&
        other.id == id &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.title == title &&
        other.lastModify == lastModify;
  }

  @override
  int get hashCode => id.hashCode ^ description.hashCode ^ isCompleted.hashCode;

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'] as String,
      title: json['title'] as String,
      lastModify: DateTime.parse(json['lastModify'] as String),
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'lastModify': lastModify.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}