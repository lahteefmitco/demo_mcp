import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/chat_db_viewer/chat_db_viewer_cubit.dart';
import '../cubits/chat_db_viewer/chat_db_viewer_state.dart';
import '../database/chat_database.dart';

class ChatDbViewerScreen extends StatefulWidget {
  const ChatDbViewerScreen({super.key});

  @override
  State<ChatDbViewerScreen> createState() => _ChatDbViewerScreenState();
}

class _ChatDbViewerScreenState extends State<ChatDbViewerScreen>
    with SingleTickerProviderStateMixin {
  late final ChatDatabase _database;
  late final TabController _tabController;
  late final ChatDbViewerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _database = ChatDatabase();
    _tabController = TabController(length: 2, vsync: this);
    _cubit = ChatDbViewerCubit(database: _database)..load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cubit.close();
    _database.close();
    super.dispose();
  }

  Future<void> _deleteSession(int sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text(
          'Are you sure you want to delete this chat session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cubit.deleteSession(sessionId);
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'Are you sure you want to delete ALL chat history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cubit.deleteAllData();
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ChatDbViewerCubit, ChatDbViewerState>(
        buildWhen: (p, n) =>
            p.isLoading != n.isLoading ||
            p.sessions != n.sessions ||
            p.sessionMessages != n.sessionMessages,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chat History'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: _deleteAllData,
                  tooltip: 'Delete All',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _cubit.load(),
                  tooltip: 'Refresh',
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Sessions'),
                  Tab(text: 'Messages'),
                ],
              ),
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSessionsTab(state),
                      _buildMessagesTab(state),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSessionsTab(ChatDbViewerState state) {
    if (state.sessions.isEmpty) {
      return const Center(child: Text('No chat sessions found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.sessions.length,
      itemBuilder: (context, index) {
        final session = state.sessions[index];
        final messages = state.sessionMessages[session.id] ?? [];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('Session #${session.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Model: ${session.model}'),
                Text('Created: ${_formatDateTime(session.createdAt)}'),
                Text('Messages: ${messages.length}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteSession(session.id),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildMessagesTab(ChatDbViewerState state) {
    if (state.sessions.isEmpty) {
      return const Center(child: Text('No chat sessions found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.sessions.length,
      itemBuilder: (context, index) {
        final session = state.sessions[index];
        final messages = state.sessionMessages[session.id] ?? [];

        return ExpansionTile(
          title: Text('Session #${session.id} (${session.model})'),
          subtitle: Text(_formatDateTime(session.createdAt)),
          children: messages.map((msg) {
            final isUser = msg.role == 'user';
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFE0F2F1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFF0E7490)
                      : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? const Color(0xFF0E7490) : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          msg.role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatDateTime(msg.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(msg.content),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
