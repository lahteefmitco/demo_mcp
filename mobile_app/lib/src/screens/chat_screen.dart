import 'package:flutter/material.dart';

import '../api/chat_api.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatApi _chatApi = ChatApi();
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = const [
    ChatMessage(
      role: 'assistant',
      content:
          'Hi, I can help you analyze spending, list expenses, and create new expense entries.',
    ),
  ].toList();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _controller.clear();
      _isSending = true;
    });

    try {
      final reply = await _chatApi.sendMessage(_messages);
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          ChatMessage(
            role: 'assistant',
            content: reply.isEmpty ? 'Done.' : reply,
          ),
        );
      });
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
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
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
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Ask like: add lunch 250 rupees today',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isSending ? null : _send,
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
