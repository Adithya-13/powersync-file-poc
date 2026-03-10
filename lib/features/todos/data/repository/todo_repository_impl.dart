import '../../domain/entity/todo.dart';
import '../../domain/repository/todo_repository.dart';
import '../datasource/todo_datasource.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoDatasource datasource;

  TodoRepositoryImpl(this.datasource);

  @override
  Future<List<Todo>> getTodos() => datasource.getTodos();

  @override
  Future<void> createTodo(String title) => datasource.createTodo(title);

  @override
  Future<void> updateTodo(String id, bool completed) =>
      datasource.updateTodo(id, completed);

  @override
  Future<void> deleteTodo(String id) => datasource.deleteTodo(id);
}
