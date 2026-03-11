import 'package:image_picker/image_picker.dart';
import 'package:powersync_core/attachments/attachments.dart';
import 'package:powersync_core/powersync_core.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/todo.dart';

class TodoDatasource {
  final PowerSyncDatabase database;
  final AttachmentQueue attachmentQueue;
  static const _uuid = Uuid();

  TodoDatasource(this.database, this.attachmentQueue);

  Stream<List<Todo>> watchTodos() {
    return database
        .watch('SELECT * FROM todos ORDER BY created_at DESC')
        .map((results) => results.map(_rowToTodo).toList());
  }

  Future<void> addTodo(String description, String createdBy) async {
    await database.execute(
      'INSERT INTO todos (id, created_by, description, completed, created_at) '
      'VALUES (?, ?, ?, 0, ?)',
      [_uuid.v4(), createdBy, description, DateTime.now().toIso8601String()],
    );
  }

  Future<void> toggleTodo(String id, bool completed) async {
    await database.execute('UPDATE todos SET completed = ? WHERE id = ?', [
      completed ? 1 : 0,
      id,
    ]);
  }

  Future<void> deleteTodo(String id) async {
    await database.execute('DELETE FROM todos WHERE id = ?', [id]);
  }

  Future<void> attachPhoto(String todoId, XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();

    await attachmentQueue.saveFile(
      data: Stream.value(bytes),
      mediaType: 'image/jpeg',
      fileExtension: 'jpg',
      updateHook: (tx, attachment) async {
        await tx.execute('UPDATE todos SET photo_id = ? WHERE id = ?', [
          attachment.id,
          todoId,
        ]);
      },
    );
  }

  Todo _rowToTodo(Map<String, dynamic> row) => Todo(
    id: row['id'] as String,
    createdBy: row['created_by'] as String,
    description: row['description'] as String,
    completed: (row['completed'] as int) == 1,
    photoId: row['photo_id'] as String?,
    createdAt: DateTime.parse(row['created_at'] as String),
  );
}
