import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openFinanceExecutorImpl() {
  return WebDatabase('finance');
}

QueryExecutor openChatExecutorImpl() {
  return WebDatabase('chat_history');
}

QueryExecutor openInMemoryExecutorImpl() {
  // WebDatabase persists in IndexedDB; good enough for tests in web contexts.
  return WebDatabase('test_db');
}
