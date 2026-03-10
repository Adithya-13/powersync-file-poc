class Todo {
  final String id;
  final String createdBy;
  final String description;
  final bool completed;
  final String? photoId;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.createdBy,
    required this.description,
    required this.completed,
    this.photoId,
    required this.createdAt,
  });

  Todo copyWith({
    String? id,
    String? createdBy,
    String? description,
    bool? completed,
    String? photoId,
    DateTime? createdAt,
  }) => Todo(
    id: id ?? this.id,
    createdBy: createdBy ?? this.createdBy,
    description: description ?? this.description,
    completed: completed ?? this.completed,
    photoId: photoId ?? this.photoId,
    createdAt: createdAt ?? this.createdAt,
  );
}
