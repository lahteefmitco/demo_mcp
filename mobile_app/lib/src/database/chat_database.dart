import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'chat_database.g.dart';

@DataClassName('ChatSessionData')
class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get model => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('ChatMessageData')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(ChatSessions, #id)();
  TextColumn get role => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [ChatSessions, ChatMessages])
class ChatDatabase extends _$ChatDatabase {
  ChatDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> createSession(String model) async {
    return into(chatSessions).insert(
      ChatSessionsCompanion.insert(model: model, createdAt: DateTime.now()),
    );
  }

  Future<int> addMessage(int sessionId, String role, String content) async {
    return into(chatMessages).insert(
      ChatMessagesCompanion.insert(
        sessionId: sessionId,
        role: role,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<ChatSessionData>> getAllSessions() {
    return (select(
      chatSessions,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<List<ChatMessageData>> getMessagesForSession(int sessionId) {
    return (select(chatMessages)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<List<ChatSessionData>> watchAllSessions() {
    return (select(
      chatSessions,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<void> deleteSession(int sessionId) async {
    await (delete(
      chatMessages,
    )..where((t) => t.sessionId.equals(sessionId))).go();
    await (delete(chatSessions)..where((t) => t.id.equals(sessionId))).go();
  }

  Future<void> deleteAllData() async {
    await delete(chatMessages).go();
    await delete(chatSessions).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'chat_history.db'));
    return NativeDatabase.createInBackground(file);
  });
}
