import '../entity/todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<void> createTodo(String title);
  Future<void> updateTodo(String id, bool completed);
  Future<void> deleteTodo(String id);
}
