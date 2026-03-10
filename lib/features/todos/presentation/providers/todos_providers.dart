import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync_core/powersync_core.dart';

import '../../../../core/database/powersync.dart';
import '../../data/datasource/todo_datasource.dart';
import '../../data/repository/todo_repository_impl.dart';
import '../../domain/entity/todo.dart';
import '../../domain/repository/todo_repository.dart';
import '../../domain/usecase/add_todo_usecase.dart';
import '../../domain/usecase/delete_todo_usecase.dart';
import '../../domain/usecase/toggle_todo_usecase.dart';
import '../../domain/usecase/watch_todos_usecase.dart';

final todoDatasourceProvider = Provider<TodoDatasource>((ref) {
  return TodoDatasource(ref.watch(powerSyncDbProvider));
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(ref.watch(todoDatasourceProvider));
});

final watchTodosUseCaseProvider = Provider<WatchTodosUseCase>((ref) {
  return WatchTodosUseCase(ref.watch(todoRepositoryProvider));
});

final addTodoUseCaseProvider = Provider<AddTodoUseCase>((ref) {
  return AddTodoUseCase(ref.watch(todoRepositoryProvider));
});

final toggleTodoUseCaseProvider = Provider<ToggleTodoUseCase>((ref) {
  return ToggleTodoUseCase(ref.watch(todoRepositoryProvider));
});

final deleteTodoUseCaseProvider = Provider<DeleteTodoUseCase>((ref) {
  return DeleteTodoUseCase(ref.watch(todoRepositoryProvider));
});

final todosStreamProvider = StreamProvider<List<Todo>>((ref) {
  return ref.watch(watchTodosUseCaseProvider).call();
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(powerSyncDbProvider).statusStream;
});
