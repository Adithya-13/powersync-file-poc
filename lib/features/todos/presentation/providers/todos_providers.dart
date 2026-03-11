import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync_core/attachments/attachments.dart';

import '../../../../core/attachments/attachments_providers.dart';
import '../../../../core/database/powersync.dart';
import '../../data/datasource/todo_datasource.dart';
import '../../data/repository/todo_repository_impl.dart';
import '../../domain/entity/todo.dart';
import '../../domain/repository/todo_repository.dart';
import '../../domain/usecase/add_todo_photo_usecase.dart';
import '../../domain/usecase/add_todo_usecase.dart';
import '../../domain/usecase/delete_todo_usecase.dart';
import '../../domain/usecase/toggle_todo_usecase.dart';
import '../../domain/usecase/watch_todos_usecase.dart';

final todoDatasourceProvider = Provider<TodoDatasource>((ref) {
  return TodoDatasource(
    ref.watch(powerSyncDbProvider),
    ref.watch(attachmentQueueProvider),
  );
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

final addTodoPhotoUseCaseProvider = Provider<AddTodoPhotoUseCase>((ref) {
  return AddTodoPhotoUseCase(ref.watch(todoRepositoryProvider));
});

final toggleTodoUseCaseProvider = Provider<ToggleTodoUseCase>((ref) {
  return ToggleTodoUseCase(ref.watch(todoRepositoryProvider));
});

final deleteTodoUseCaseProvider = Provider<DeleteTodoUseCase>((ref) {
  return DeleteTodoUseCase(ref.watch(todoRepositoryProvider));
});

final todosProvider = StreamProvider<List<Todo>>((ref) {
  return ref.watch(watchTodosUseCaseProvider).call();
});

final attachmentsProvider = StreamProvider<Map<String, Attachment>>((ref) {
  final db = ref.watch(powerSyncDbProvider);
  return db
      .watch('''
    SELECT id, filename, local_uri, media_type, size, timestamp, state, has_synced, meta_data
    FROM ${AttachmentsQueueTable.defaultTableName}
  ''')
      .map((results) {
        final attachmentsById = <String, Attachment>{};
        for (final row in results) {
          final attachment = Attachment.fromRow(row);
          attachmentsById[attachment.id] = attachment;
        }
        return attachmentsById;
      });
});
