import '../repository/todo_repository.dart';

class AddTodoUseCase {
  final TodoRepository repository;

  AddTodoUseCase(this.repository);

  Future<void> call(String description, String createdBy) =>
      repository.addTodo(description, createdBy);
}
