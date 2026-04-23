import '../../models/help_chat_models.dart';

class HelpChatUiMessage {
  const HelpChatUiMessage({
    required this.role,
    required this.content,
    this.citations = const [],
  });

  final String role; // system|user|assistant (system not shown)
  final String content;
  final List<HelpCitation> citations;
}

class HelpChatState {
  const HelpChatState({
    required this.messages,
    required this.isSending,
    required this.toastNonce,
    this.toastMessage,
    required this.toastIsError,
  });

  final List<HelpChatUiMessage> messages;
  final bool isSending;

  final int toastNonce;
  final String? toastMessage;
  final bool toastIsError;

  const HelpChatState.initial()
    : messages = const [],
      isSending = false,
      toastNonce = 0,
      toastMessage = null,
      toastIsError = false;

  HelpChatState copyWith({
    List<HelpChatUiMessage>? messages,
    bool? isSending,
    int? toastNonce,
    String? toastMessage,
    bool? toastIsError,
  }) {
    return HelpChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      toastNonce: toastNonce ?? this.toastNonce,
      toastMessage: toastMessage,
      toastIsError: toastIsError ?? this.toastIsError,
    );
  }
}

