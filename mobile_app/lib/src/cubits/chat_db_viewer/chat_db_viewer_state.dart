import '../../database/chat_database.dart';

class ChatDbViewerState {
  const ChatDbViewerState({
    required this.isLoading,
    required this.sessions,
    required this.sessionMessages,
  });

  final bool isLoading;
  final List<ChatSessionData> sessions;
  final Map<int, List<ChatMessageData>> sessionMessages;

  const ChatDbViewerState.initial()
      : isLoading = true,
        sessions = const [],
        sessionMessages = const {};

  ChatDbViewerState copyWith({
    bool? isLoading,
    List<ChatSessionData>? sessions,
    Map<int, List<ChatMessageData>>? sessionMessages,
  }) {
    return ChatDbViewerState(
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      sessionMessages: sessionMessages ?? this.sessionMessages,
    );
  }
}

