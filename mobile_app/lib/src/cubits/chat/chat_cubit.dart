import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/chat_api.dart';
import '../../api/finance_mcp_client.dart';
import '../../database/chat_database.dart';
import '../../models/chat_message.dart';
import '../../settings/app_preferences_storage.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required String token, required String currencySymbol})
    : _currencySymbol = currencySymbol,
      _chatApi = ChatApi(token: token),
      _financeClient = FinanceMcpClient(token: token),
      _database = ChatDatabase(),
      _preferencesStorage = AppPreferencesStorage(),
      super(const ChatState.initial());

  final String _currencySymbol;
  final ChatApi _chatApi;
  final FinanceMcpClient _financeClient;
  final ChatDatabase _database;
  final AppPreferencesStorage _preferencesStorage;

  static const providers = <String, String>{
    'gemini': 'Gemini',
    'mistral': 'Mistral',
    'openrouter': 'OpenRouter',
    'sarvam': 'Sarvam (105B)',
  };

  static const defaultProvider = 'gemini';
  static const _apiAllowedProviders = {'gemini', 'mistral', 'openrouter'};

  String _providerForApi(String selectedProvider) {
    final normalized = selectedProvider.trim().toLowerCase();
    if (_apiAllowedProviders.contains(normalized)) return normalized;

    // Backend deployments may not support Sarvam as a provider; route it through a supported provider.
    if (normalized == 'sarvam') return 'openrouter';

    return defaultProvider;
  }

  Future<void> initialize() async {
    await _restoreSelectedProvider();
    startNewSession();
  }

  @override
  Future<void> close() async {
    return super.close();
  }

  Future<List<ChatSessionData>> getAllSessions() => _database.getAllSessions();

  Future<void> deleteSession(int id) => _database.deleteSession(id);

  void startNewSession() {
    emit(
      state.copyWith(
        currentSessionId: null,
        messages: [
          ChatUiMessage(
            role: 'assistant',
            content:
                'Hi, I can help you analyze spending, list expenses, and create new expense entries. Ask me to show charts like "show me today\'s expenses in bar chart" or "show weekly expenses in line chart" or "show expenses by category as pie chart".',
          ),
        ],
      ),
    );
  }

  Future<void> reloadCurrentSessionFromLocalDb() async {
    final id = state.currentSessionId;
    if (id == null) return;
    final messages = await _database.getMessagesForSessionAsUi(id);
    emit(state.copyWith(messages: messages));
  }

  Future<void> loadSession(ChatSessionData session) async {
    emit(state.copyWith(isLoadingSessions: true));

    final messages = await _database.getMessagesForSessionAsUi(session.id);
    emit(
      state.copyWith(
        currentSessionId: session.id,
        selectedProvider: session.model,
        messages: messages,
        isLoadingSessions: false,
      ),
    );
  }

  Future<void> setSelectedProvider(String value) async {
    await _preferencesStorage.writeChatAgent(value);
    emit(state.copyWith(selectedProvider: value));
  }

  Future<void> _restoreSelectedProvider() async {
    final savedProvider = await _preferencesStorage.readChatAgent();
    if (savedProvider == null || !providers.containsKey(savedProvider)) {
      emit(state.copyWith(selectedProvider: defaultProvider));
      return;
    }
    emit(state.copyWith(selectedProvider: savedProvider));
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    var sessionId = state.currentSessionId;
    if (sessionId == null) {
      sessionId = await _database.createSession(state.selectedProvider);
      emit(state.copyWith(currentSessionId: sessionId));
    }

    final isChart = _isChartRequest(trimmed);
    log("isChart: $isChart");
    ChatChartData? chartData;

    if (isChart) {
      chartData = await _fetchChartFromBackend(trimmed);
      log("chartData: $chartData");
    }

    final updatedMessages = [
      ...state.messages,
      ChatUiMessage(role: 'user', content: trimmed),
      if (chartData != null)
        ChatUiMessage(
          role: 'assistant',
          content: chartData.title,
          chartData: chartData,
        ),
    ];

    emit(state.copyWith(messages: updatedMessages, isSending: true));

    await _database.addMessage(sessionId, 'user', trimmed);

    if (chartData == null && isChart) {
      final msg = ChatUiMessage(
        role: 'assistant',
        content: 'No expense data found for the requested period.',
      );
      emit(state.copyWith(messages: [...state.messages, msg]));
      await _database.addMessage(
        sessionId,
        'assistant',
        'No expense data found.',
      );
    } else if (chartData == null) {
      try {
        final result = await _chatApi.sendMessage(
          state.messages
              .where((m) => m.chartData == null)
              .map((m) => ChatMessage(role: m.role, content: m.content))
              .toList(),
          provider: _providerForApi(state.selectedProvider),
        );

        final replyContent = result.reply.isEmpty
            ? (result.isError ? 'Something went wrong.' : 'Done.')
            : result.reply;
        final msg = ChatUiMessage(
          role: 'assistant',
          content: replyContent,
          isError: result.isError,
        );
        emit(state.copyWith(messages: [...state.messages, msg]));
        await _database.addMessage(
          sessionId,
          'assistant',
          replyContent,
          isError: result.isError,
        );
      } catch (e) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        final msg = ChatUiMessage(
          role: 'assistant',
          content: errorMsg,
          isError: true,
        );
        emit(
          state.copyWith(
            messages: [...state.messages, msg],
            isSending: false,
          ),
        );
        await _database.addMessage(
          sessionId,
          'assistant',
          errorMsg,
          isError: true,
        );
        return;
      }
    } else {
      await _database.addMessage(sessionId, 'assistant', chartData.title);
    }

    emit(state.copyWith(isSending: false));
  }

  Future<String?> transcribeSpeech(
    Uint8List audioBytes,
    String mimeType,
  ) async {
    if (state.isSending || state.isTranscribing) return null;

    emit(state.copyWith(isTranscribing: true));
    try {
      final transcript = await _chatApi.transcribeAudio(
        audioBytes: audioBytes,
        mimeType: mimeType,
      );
      emit(state.copyWith(isTranscribing: false));
      return transcript;
    } catch (e) {
      emit(
        state
            .copyWith(isTranscribing: false)
            .toastError(e.toString().replaceFirst('Exception: ', '')),
      );
      return null;
    }
  }

  String? _detectChartPeriod(String text) {
    final lower = text.toLowerCase();

    // "last 7 days", "past 30 days" — use one `\` in raw strings so `\s`/`\d` work.
    final daysMatch = RegExp(
      r'(?:past|last)\s+(\d+)\s+days?',
      caseSensitive: false,
    ).firstMatch(lower);
    if (daysMatch != null) {
      final days = int.tryParse(daysMatch.group(1) ?? '');
      if (days != null && days > 0) {
        return 'days_$days';
      }
    }

    if (lower.contains("today") || lower.contains("today's")) {
      return 'today';
    }
    if (lower.contains('week') && !lower.contains('month')) {
      return 'weekly';
    }
    if (lower.contains('month') && !lower.contains('week')) {
      return 'monthly';
    }
    if (lower.contains('category') ||
        lower.contains('by category') ||
        lower.contains('categories')) {
      return 'category';
    }

    return null;
  }

  String _detectChartType(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('pie')) return 'pie';
    if (lower.contains('line')) return 'line';
    return 'bar';
  }

  bool _isChartRequest(String text) {
    final lower = text.toLowerCase();
    return lower.contains('chart') ||
        lower.contains('graph') ||
        (lower.contains('show') && lower.contains('expense'));
  }

  Future<ChatChartData?> _fetchChartFromBackend(String text) async {
    final period = _detectChartPeriod(text);
    log("period: $period");
    if (period == null) return null;

    final type = _detectChartType(text);

    try {
      final chartData = await _financeClient.fetchChartData(
        type: type,
        period: period,
      );

      log("chartData from backend: $chartData");

      if (chartData.data.isEmpty) {
        return null;
      }

      return ChatChartData(
        type: chartData.type,
        title: chartData.title,
        data: chartData.data
            .map((d) => ChatChartPoint(label: d.label, value: d.value))
            .toList(),
        currencySymbol: _currencySymbol,
      );
    } catch (e) {
      log("Error fetching chart: $e");
      return null;
    }
  }
}
