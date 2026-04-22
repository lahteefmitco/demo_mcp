import 'package:flutter_bloc/flutter_bloc.dart';

import '../../database/chat_database.dart';
import 'chat_db_viewer_state.dart';

class ChatDbViewerCubit extends Cubit<ChatDbViewerState> {
  ChatDbViewerCubit({required ChatDatabase database})
    : _database = database,
      super(const ChatDbViewerState.initial());

  final ChatDatabase _database;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final sessions = await _database.getAllSessions();
    final messages = <int, List<ChatMessageData>>{};
    for (final session in sessions) {
      messages[session.id] = await _database.getMessagesForSession(session.id);
    }
    emit(
      state.copyWith(
        isLoading: false,
        sessions: sessions,
        sessionMessages: messages,
      ),
    );
  }

  Future<void> deleteSession(int sessionId) async {
    await _database.deleteSession(sessionId);
    await load();
  }

  Future<void> deleteAllData() async {
    await _database.deleteAllData();
    await load();
  }
}
