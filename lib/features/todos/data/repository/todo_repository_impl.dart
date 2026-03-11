import 'package:image_picker/image_picker.dart';

import '../../domain/entity/todo.dart';
import '../../domain/repository/todo_repository.dart';
import '../datasource/todo_datasource.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoDatasource datasource;

  TodoRepositoryImpl(this.datasource);

  @override
  Stream<List<Todo>> watchTodos() => datasource.watchTodos();

  @override
  Future<void> addTodo(String description, String createdBy) =>
      datasource.addTodo(description, createdBy);

  @override
  Future<void> toggleTodo(String id, bool completed) =>
      datasource.toggleTodo(id, completed);

  @override
  Future<void> deleteTodo(String id) => datasource.deleteTodo(id);

  @override
  Future<void> attachPhoto(String todoId, XFile imageFile) =>
      datasource.attachPhoto(todoId, imageFile);

  @override
  Future<void> deletePhoto(String todoId) => datasource.deletePhoto(todoId);
}
