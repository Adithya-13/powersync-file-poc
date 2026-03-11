import 'package:image_picker/image_picker.dart';

import '../repository/todo_repository.dart';

class AddTodoPhotoUseCase {
  final TodoRepository repository;

  AddTodoPhotoUseCase(this.repository);

  Future<void> call(String todoId, XFile imageFile) =>
      repository.attachPhoto(todoId, imageFile);
}
