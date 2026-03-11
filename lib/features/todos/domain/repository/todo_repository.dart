import 'package:image_picker/image_picker.dart';

import '../entity/todo.dart';

abstract class TodoRepository {
  Stream<List<Todo>> watchTodos();
  Future<void> addTodo(String description, String createdBy);
  Future<void> toggleTodo(String id, bool completed);
  Future<void> deleteTodo(String id);
  Future<void> attachPhoto(String todoId, XFile imageFile);
}
