import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entity/todo.dart';
import '../providers/todos_providers.dart';

class TodoItemWidget extends ConsumerWidget {
  final Todo todo;

  const TodoItemWidget({required this.todo, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(deleteTodoUseCaseProvider).call(todo.id);
      },
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (val) {
            ref.read(toggleTodoUseCaseProvider).call(todo.id, val ?? false);
          },
        ),
        title: Text(
          todo.description,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            color: todo.completed ? Colors.grey : null,
          ),
        ),
        subtitle: Text(todo.createdAt.toString().substring(0, 10)),
      ),
    );
  }
}
