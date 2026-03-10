import '../entity/todo.dart';
import '../repository/todo_repository.dart';

class WatchTodosUseCase {
  final TodoRepository repository;

  WatchTodosUseCase(this.repository);

  Stream<List<Todo>> call() => repository.watchTodos();
}
