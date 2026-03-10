import 'package:powersync_core/powersync_core.dart';

import '../../domain/entity/todo.dart';

class TodoDatasource {
  final PowerSyncDatabase database;

  TodoDatasource(this.database);

  Future<List<Todo>> getTodos() async {
    // TODO: Implement fetching todos from PowerSync
    return [];
  }

  Future<void> createTodo(String title) async {
    // TODO: Implement creating todo in PowerSync
  }

  Future<void> updateTodo(String id, bool completed) async {
    // TODO: Implement updating todo in PowerSync
  }

  Future<void> deleteTodo(String id) async {
    // TODO: Implement deleting todo in PowerSync
  }
}
