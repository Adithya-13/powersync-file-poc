import 'package:powersync_core/powersync_core.dart';

import '../../domain/entity/todo.dart';

class TodoDatasource {
  final PowerSyncDatabase database;

  TodoDatasource(this.database);

  Stream<List<Todo>> watchTodos() {
    // TODO: implement via db.watch('SELECT * FROM todos ORDER BY created_at DESC')
    return const Stream.empty();
  }

  Future<void> addTodo(String description, String createdBy) async {
    // TODO: implement via db.execute('INSERT INTO todos ...')
  }

  Future<void> toggleTodo(String id, bool completed) async {
    // TODO: implement via db.execute('UPDATE todos SET completed = ? WHERE id = ?')
  }

  Future<void> deleteTodo(String id) async {
    // TODO: implement via db.execute('DELETE FROM todos WHERE id = ?')
  }
}
