import '../repository/todo_repository.dart';

class DeleteTodoPhotoUseCase {
  final TodoRepository repository;

  DeleteTodoPhotoUseCase(this.repository);

  Future<void> call(String todoId) => repository.deletePhoto(todoId);
}
