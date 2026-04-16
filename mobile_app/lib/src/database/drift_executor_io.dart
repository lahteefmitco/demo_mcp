import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openFinanceExecutorImpl() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'finance.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

QueryExecutor openChatExecutorImpl() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'chat_history.db'));
    return NativeDatabase.createInBackground(file);
  });
}

QueryExecutor openInMemoryExecutorImpl() {
  return NativeDatabase.memory();
}

