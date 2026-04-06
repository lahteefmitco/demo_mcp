import 'package:flutter/material.dart';

import '../api/chat_api.dart';
import '../database/chat_database.dart';
import '../models/auth_session.dart';
import '../models/chat_message.dart';
import '../settings/app_preferences_storage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.session,
    required this.onOpenProfile,
    super.key,
  });

  final AuthSession session;
  final Future<void> Function() onOpenProfile;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatApi _chatApi;
  late final ChatDatabase _database;
  final AppPreferencesStorage _preferencesStorage = AppPreferencesStorage();
  final TextEditingController _controller = TextEditingController();
  static const _providers = <String, String>{
    'gemini': 'Gemini',
    'mistral': 'Mistral',
    'openrouter': 'OpenRouter',
  };
  static const _defaultProvider = 'gemini';
  final List<ChatMessage> _messages = const [
    ChatMessage(
      role: 'assistant',
      content:
          'Hi, I can help you analyze spending, list expenses, and create new expense entries.',
    ),
  ].toList();
  bool _isSending = false;
  String _selectedProvider = _defaultProvider;
  int? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _chatApi = ChatApi(token: widget.session.token);
    _database = ChatDatabase();
    _restoreSelectedProvider();
  }

  @override
  void dispose() {
    _controller.dispose();
    _database.close();
    super.dispose();
  }

  Future<void> _restoreSelectedProvider() async {
    final savedProvider = await _preferencesStorage.readChatAgent();
    if (!mounted ||
        savedProvider == null ||
        !_providers.containsKey(savedProvider)) {
      return;
    }

    setState(() {
      _selectedProvider = savedProvider;
    });
  }

  Future<void> _setSelectedProvider(String value) async {
    await _preferencesStorage.writeChatAgent(value);
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedProvider = value;
    });
  }

  Future<void> _startNewSession() async {
    _currentSessionId = await _database.createSession(_selectedProvider);
    for (final msg in _messages) {
      await _database.addMessage(_currentSessionId!, msg.role, msg.content);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    if (_currentSessionId == null) {
      await _startNewSession();
    }

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _controller.clear();
      _isSending = true;
    });

    await _database.addMessage(_currentSessionId!, 'user', text);

    try {
      final reply = await _chatApi.sendMessage(
        _messages,
        provider: _selectedProvider,
      );
      if (!mounted) {
        return;
      }

      final replyContent = reply.isEmpty ? 'Done.' : reply;
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: replyContent));
      });
      await _database.addMessage(_currentSessionId!, 'assistant', replyContent);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat'),
            Text(
              widget.session.user.name,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: widget.onOpenProfile,
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text('Agent'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedProvider,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _providers.entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: _isSending
                        ? null
                        : (value) async {
                            if (value == null) {
                              return;
                            }
                            await _setSelectedProvider(value);
                          },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isUser = message.role == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF0E7490) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Thinking...'),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 2,
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Ask like: add lunch 250 rupees 02-04-2026',
                      hintStyle: TextStyle(color: Colors.black38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _isSending ? null : _send,
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: const Color(0xFF0E7490),
                    foregroundColor: Colors.white,
                    iconSize: 36,
                  ),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
