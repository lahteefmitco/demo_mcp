import 'package:drift/drift.dart';

import 'drift_executor_stub.dart'
    if (dart.library.io) 'drift_executor_io.dart'
    if (dart.library.html) 'drift_executor_web.dart';

/// Opens the main finance database executor.
QueryExecutor openFinanceExecutor() => openFinanceExecutorImpl();

/// Opens the chat history database executor.
QueryExecutor openChatExecutor() => openChatExecutorImpl();

/// Opens an executor suitable for tests.
QueryExecutor openInMemoryExecutor() => openInMemoryExecutorImpl();
