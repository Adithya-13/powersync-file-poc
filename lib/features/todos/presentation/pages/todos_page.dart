import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/todos_providers.dart';
import '../widgets/todo_item_widget.dart';

class TodosPage extends ConsumerStatefulWidget {
  const TodosPage({super.key});

  @override
  ConsumerState<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends ConsumerState<TodosPage> {
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    final description = _descriptionController.text.trim();
    final userId = ref.read(userIdProvider);

    if (description.isEmpty || userId == null) {
      return;
    }

    await ref.read(addTodoUseCaseProvider).call(description, userId);
    _descriptionController.clear();
  }

  Future<void> _attachPhoto(String todoId) async {
    final imageFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (imageFile == null) {
      return;
    }

    await ref.read(addTodoPhotoUseCaseProvider).call(todoId, imageFile);
  }

  Future<void> _deletePhoto(String todoId) async {
    await ref.read(deleteTodoPhotoUseCaseProvider).call(todoId);
  }

  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todosProvider);
    final attachmentsById = ref.watch(attachmentsProvider).valueOrNull ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'New todo',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _runAction(context, _addTodo),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _runAction(context, _addTodo),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: todosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (todos) {
                if (todos.isEmpty) {
                  return const Center(child: Text('No todos yet'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    final attachment = todo.photoId == null
                        ? null
                        : attachmentsById[todo.photoId];

                    return TodoItemWidget(
                      todo: todo,
                      attachment: attachment,
                      onToggle: (completed) => _runAction(
                        context,
                        () => ref
                            .read(toggleTodoUseCaseProvider)
                            .call(todo.id, completed),
                      ),
                      onDelete: () => _runAction(
                        context,
                        () => ref.read(deleteTodoUseCaseProvider).call(todo.id),
                      ),
                      onAttachPhoto: () =>
                          _runAction(context, () => _attachPhoto(todo.id)),
                      onDeletePhoto: () => _runAction(
                        context,
                        () => _deletePhoto(todo.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _runAction(context, _addTodo),
        child: const Icon(Icons.add),
      ),
    );
  }
}
