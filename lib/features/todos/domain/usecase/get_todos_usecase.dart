import '../entity/todo.dart';
import '../repository/todo_repository.dart';

class GetTodosUseCase {
  final TodoRepository repository;

  GetTodosUseCase(this.repository);

  Future<List<Todo>> call() => repository.getTodos();
}
