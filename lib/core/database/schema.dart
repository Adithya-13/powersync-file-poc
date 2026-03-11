import 'package:powersync_core/attachments/attachments.dart';
import 'package:powersync_core/powersync_core.dart';

const todos = Table('todos', [
  Column.text('created_by'),
  Column.text('description'),
  Column.integer('completed'),
  Column.text('photo_id'),
  Column.text('created_at'),
]);

final attachmentsQueue = AttachmentsQueueTable();

final schema = Schema([todos, attachmentsQueue]);
