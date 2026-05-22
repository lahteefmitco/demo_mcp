import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

const _sqlite3Wasm = 'sqlite3.wasm';
const _driftWorker = 'drift_worker.js';

QueryExecutor _openWasmExecutor(String databaseName) {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: databaseName,
      sqlite3Uri: Uri.parse(_sqlite3Wasm),
      driftWorkerUri: Uri.parse(_driftWorker),
    );
    return result.resolvedExecutor;
  });
}

QueryExecutor openFinanceExecutorImpl() => _openWasmExecutor('finance');

QueryExecutor openChatExecutorImpl() => _openWasmExecutor('chat_history');

QueryExecutor openInMemoryExecutorImpl() => _openWasmExecutor('test_db');
