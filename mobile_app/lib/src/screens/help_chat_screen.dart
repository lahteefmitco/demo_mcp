import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../cubits/help_chat/help_chat_cubit.dart';
import '../cubits/help_chat/help_chat_state.dart';
import '../models/help_chat_models.dart';
import '../utils/toast.dart';

class HelpChatScreen extends StatelessWidget {
  const HelpChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HelpChatCubit()..initialize(),
      child: BlocConsumer<HelpChatCubit, HelpChatState>(
        listenWhen: (p, n) => p.toastNonce != n.toastNonce,
        listener: (context, state) {
          final msg = state.toastMessage;
          if (msg == null || msg.isEmpty) return;
          if (state.toastIsError) {
            AppToast.error(context, msg);
          } else {
            AppToast.success(context, msg);
          }
        },
        buildWhen: (p, n) => p.messages != n.messages || p.isSending != n.isSending,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Help Chat')),
            body: Column(
              children: [
                Expanded(child: _HelpMessagesList(messages: state.messages)),
                _HelpComposer(isSending: state.isSending),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HelpMessagesList extends StatelessWidget {
  const _HelpMessagesList({required this.messages});

  final List<HelpChatUiMessage> messages;

  @override
  Widget build(BuildContext context) {
    final visible = messages.where((m) => m.role != 'system').toList();

    if (visible.isEmpty) {
      return const Center(child: Text('Ask a question to get started.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final msg = visible[index];
        final isUser = msg.role == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              color: isUser ? const Color(0xFF0E7490) : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUser)
                      Text(
                        msg.content,
                        style: const TextStyle(color: Colors.white),
                      )
                    else
                      MarkdownBody(data: msg.content),
                    if (!isUser && msg.citations.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _Citations(citations: msg.citations),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Citations extends StatelessWidget {
  const _Citations({required this.citations});

  final List<HelpCitation> citations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sources',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 6),
        ...citations.map((c) {
          final section = (c.section ?? '').trim();
          final suffix = section.isEmpty ? '' : ' • $section';
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '- ${c.title}$suffix',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }),
      ],
    );
  }
}

class _HelpComposer extends StatefulWidget {
  const _HelpComposer({required this.isSending});

  final bool isSending;

  @override
  State<_HelpComposer> createState() => _HelpComposerState();
}

class _HelpComposerState extends State<_HelpComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    _controller.clear();
    await context.read<HelpChatCubit>().sendMessage(text, screen: 'About');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: widget.isSending ? null : (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Ask how to use the app…',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: widget.isSending ? null : _send,
              icon: widget.isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}

