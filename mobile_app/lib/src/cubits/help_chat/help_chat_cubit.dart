import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../api/help_chat_api.dart';
import '../../auth/auth_storage.dart';
import '../../models/chat_message.dart';
import 'help_chat_state.dart';

class HelpChatCubit extends Cubit<HelpChatState> {
  HelpChatCubit({AuthStorage? authStorage})
    : _authStorage = authStorage ?? AuthStorage(),
      super(const HelpChatState.initial());

  final AuthStorage _authStorage;

  static const int defaultMaxWords = 220;

  static String buildSystemPrompt({
    required String appVersion,
    required int maxWords,
  }) {
    return '''
You are a product assistant for the mobile app described ONLY in the retrieved documentation chunks and in the [$appVersion] release notes. Your job is to help users use the app: navigation, features, and troubleshooting, using only that evidence.

Rules:
- Answer using the retrieved context. If the context is insufficient, say you don't have that in the in-app help and suggest what the user can try (e.g. check Settings) without inventing features.
- Do not invent UI labels, screen names, settings paths, or server/API behavior. If uncertain, state the uncertainty and ask one clarifying question.
- Prefer short, scannable answers: bullets for steps, bold for key actions (Open → Tap →).
- If the user asks for financial advice, say you can only explain how to use the app, not how to invest or budget.
- Never ask for or store secrets (passwords, tokens, full card numbers, PINs).
- If the user reports a bug, capture: what they tapped, what they expected, what happened, and app version, and suggest checking network/sync status only if the docs support it.
- Cite your sources: after each major claim, add [source: <chunk_id or section title>].
- Keep answers under $maxWords words unless the user asks for a detailed walkthrough.
''';
  }

  Future<void> initialize() async {
    emit(
      state.copyWith(
        messages: const [
          HelpChatUiMessage(
            role: 'assistant',
            content:
                'Hi! Ask me how to use the app (navigation, features, troubleshooting). I’ll answer with sources from the in-app help.',
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage(String text, {String? screen}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    emit(
      state.copyWith(
        messages: [...state.messages, HelpChatUiMessage(role: 'user', content: trimmed)],
        isSending: true,
      ),
    );

    try {
      final session = await _authStorage.readSession();
      if (session == null) {
        throw Exception('You are signed out. Please sign in and try again.');
      }

      final pkg = await PackageInfo.fromPlatform();
      final appVersion = pkg.version;

      // Build messages for the backend: include system prompt (not shown in UI).
      final system = ChatMessage(
        role: 'system',
        content: buildSystemPrompt(
          appVersion: appVersion,
          maxWords: defaultMaxWords,
        ),
      );

      final convo = <ChatMessage>[
        system,
        ...state.messages
            .where((m) => m.role == 'user' || m.role == 'assistant')
            .map((m) => ChatMessage(role: m.role, content: m.content)),
        ChatMessage(role: 'user', content: trimmed),
      ];

      final api = HelpChatApi(token: session.token);
      final reply = await api.sendMessage(
        messages: convo,
        appVersion: appVersion,
        maxWords: defaultMaxWords,
        screen: screen,
      );

      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            HelpChatUiMessage(
              role: 'assistant',
              content: reply.reply.isEmpty ? 'Done.' : reply.reply,
              citations: reply.citations,
            ),
          ],
          isSending: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSending: false,
          toastNonce: state.toastNonce + 1,
          toastMessage: e.toString().replaceFirst('Exception: ', ''),
          toastIsError: true,
        ),
      );
    }
  }
}

