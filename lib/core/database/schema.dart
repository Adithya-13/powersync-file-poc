import 'package:powersync_core/powersync_core.dart';

const todos = Table('todos', [
  Column.text('created_by'),
  Column.text('description'),
  Column.integer('completed'),
  Column.text('photo_id'),
  Column.text('created_at'),
]);

// Local-only attachments queue table (not synced to remote)
const attachments = Table.localOnly('attachments', [
  Column.text('filename'),
  Column.text('local_uri'),
  Column.integer('timestamp'),
  Column.integer('size'),
  Column.text('media_type'),
  Column.integer('state'),
  Column.integer('has_synced'),
  Column.text('meta_data'),
]);

final schema = Schema([todos, attachments]);
