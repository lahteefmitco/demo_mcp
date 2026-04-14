class ChatChartPoint {
  final String label;
  final double value;

  ChatChartPoint({required this.label, required this.value});
}

class ChatChartData {
  final String type;
  final String title;
  final List<ChatChartPoint> data;
  final String? currencySymbol;

  ChatChartData({
    required this.type,
    required this.title,
    required this.data,
    this.currencySymbol,
  });
}

class ChatUiMessage {
  final String role;
  final String content;
  final ChatChartData? chartData;

  ChatUiMessage({required this.role, required this.content, this.chartData});
}

class ChatState {
  const ChatState({
    required this.messages,
    required this.isSending,
    required this.selectedProvider,
    required this.currentSessionId,
    required this.isLoadingSessions,
    required this.toastMessage,
    required this.toastIsError,
    required this.toastNonce,
  });

  final List<ChatUiMessage> messages;
  final bool isSending;
  final String selectedProvider;
  final int? currentSessionId;
  final bool isLoadingSessions;

  /// UI event: show toast when [toastNonce] changes.
  final String? toastMessage;
  final bool toastIsError;
  final int toastNonce;

  const ChatState.initial()
      : messages = const [],
        isSending = false,
        selectedProvider = 'gemini',
        currentSessionId = null,
        isLoadingSessions = false,
        toastMessage = null,
        toastIsError = false,
        toastNonce = 0;

  ChatState copyWith({
    List<ChatUiMessage>? messages,
    bool? isSending,
    String? selectedProvider,
    int? currentSessionId,
    bool? isLoadingSessions,
    String? toastMessage,
    bool? toastIsError,
    int? toastNonce,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isLoadingSessions: isLoadingSessions ?? this.isLoadingSessions,
      toastMessage: toastMessage,
      toastIsError: toastIsError ?? this.toastIsError,
      toastNonce: toastNonce ?? this.toastNonce,
    );
  }
}

extension ChatStateToast on ChatState {
  ChatState toastError(String message) {
    return copyWith(
      toastMessage: message,
      toastIsError: true,
      toastNonce: toastNonce + 1,
    );
  }
}

