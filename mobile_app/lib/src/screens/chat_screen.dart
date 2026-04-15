import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../cubits/chat/chat_cubit.dart';
import '../cubits/chat/chat_state.dart';
import '../database/chat_database.dart';
import '../models/auth_session.dart';
import '../models/currency_option.dart';
import '../utils/toast.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    required this.session,
    required this.currency,
    required this.isActiveTab,
    required this.onOpenProfile,
    super.key,
  });

  final AuthSession session;
  final CurrencyOption currency;
  final bool isActiveTab;
  final Future<void> Function() onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(
        token: session.token,
        currencySymbol: currency.symbol,
      )..initialize(),
      child: _ChatActiveWatcher(
        isActiveTab: isActiveTab,
        child: BlocConsumer<ChatCubit, ChatState>(
          listenWhen: (p, n) => p.toastNonce != n.toastNonce,
          listener: (context, state) {
            final msg = state.toastMessage;
            if (msg == null || msg.isEmpty) return;
            AppToast.error(context, msg);
          },
          buildWhen: (p, n) =>
              p.messages != n.messages ||
              p.isSending != n.isSending ||
              p.selectedProvider != n.selectedProvider,
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chat'),
                    Text(
                      session.user.name,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () => _showChatHistory(context),
                    icon: const Icon(Icons.history),
                    tooltip: 'Chat History',
                  ),
                  IconButton(
                    onPressed: onOpenProfile,
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
                            initialValue: state.selectedProvider,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: ChatCubit.providers.entries
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value),
                                  ),
                                )
                                .toList(),
                            onChanged: state.isSending
                                ? null
                                : (value) async {
                                    if (value == null) return;
                                    await context
                                        .read<ChatCubit>()
                                        .setSelectedProvider(value);
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _MessagesList(messages: state.messages)),
                  _Composer(isSending: state.isSending),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) {
      return 'Today ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
  }

  void _showChatHistory(BuildContext context) async {
    final chatCubit = context.read<ChatCubit>();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: chatCubit,
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (sheetContext, scrollController) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
                return FutureBuilder<List<ChatSessionData>>(
                  future: chatCubit.getAllSessions(),
                  builder: (context, snapshot) {
                  final sessions = snapshot.data ?? [];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chat History',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                context.read<ChatCubit>().startNewSession();
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('New Chat'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: snapshot.connectionState == ConnectionState.waiting
                            ? const Center(child: CircularProgressIndicator())
                            : sessions.isEmpty
                                ? const Center(child: Text('No chat history yet'))
                                : ListView.builder(
                                    controller: scrollController,
                                    itemCount: sessions.length,
                                    itemBuilder: (context, index) {
                                      final session = sessions[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: const Color(0xFF0E7490)
                                              .withValues(alpha: 0.1),
                                          child: Text(
                                            ChatCubit.providers[session.model]
                                                    ?.substring(0, 1) ??
                                                'C',
                                            style: const TextStyle(
                                              color: Color(0xFF0E7490),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          ChatCubit.providers[session.model] ??
                                              session.model,
                                        ),
                                        subtitle: Text(
                                          '${_formatDate(session.createdAt)} - Session #${session.id}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            await context
                                                .read<ChatCubit>()
                                                .deleteSession(session.id);
                                            setSheetState(() {});
                                          },
                                        ),
                                        onTap: () async {
                                          await context
                                              .read<ChatCubit>()
                                              .loadSession(session);
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                  );
                },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ChatActiveWatcher extends StatefulWidget {
  const _ChatActiveWatcher({
    required this.isActiveTab,
    required this.child,
  });

  final bool isActiveTab;
  final Widget child;

  @override
  State<_ChatActiveWatcher> createState() => _ChatActiveWatcherState();
}

class _ChatActiveWatcherState extends State<_ChatActiveWatcher> {
  @override
  void didUpdateWidget(_ChatActiveWatcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActiveTab && !oldWidget.isActiveTab) {
      context.read<ChatCubit>().reloadCurrentSessionFromLocalDb();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _MessagesList extends StatefulWidget {
  const _MessagesList({required this.messages});

  final List<ChatUiMessage> messages;

  @override
  State<_MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<_MessagesList> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.messages.isNotEmpty) {
      _scrollToBottom();
    }
  }

  @override
  void didUpdateWidget(covariant _MessagesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_messagesMeaningfullyChanged(oldWidget.messages, widget.messages)) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Scroll when the list is not the same instance and either length or the
  /// last bubble changed (covers new messages without scrolling on `isSending`-only rebuilds).
  static bool _messagesMeaningfullyChanged(
    List<ChatUiMessage> oldList,
    List<ChatUiMessage> newList,
  ) {
    if (identical(oldList, newList)) return false;
    if (oldList.length != newList.length) return true;
    if (oldList.isEmpty) return false;
    final o = oldList.last;
    final n = newList.last;
    return o.role != n.role ||
        o.content != n.content ||
        o.chartData != n.chartData;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      if (max <= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_scroll.hasClients) return;
          final max2 = _scroll.position.maxScrollExtent;
          _scroll.animateTo(
            max2,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });
        return;
      }
      _scroll.animateTo(
        max,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final isUser = message.role == 'user';

        if (message.chartData != null) {
          return _ExpenseChart(chartData: message.chartData!);
        }

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF0E7490) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: isUser
                ? SelectableText(
                    message.content,
                    style: const TextStyle(color: Colors.white),
                  )
                : MarkdownBody(
                    data: message.content,
                    selectable: true,
                  ),
          ),
        );
      },
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({required this.isSending});

  final bool isSending;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    _controller.clear();
    await context.read<ChatCubit>().sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                hintText: 'Ask something...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: widget.isSending ? null : _send,
            icon: widget.isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _ExpenseChart extends StatelessWidget {
  const _ExpenseChart({required this.chartData});

  final ChatChartData chartData;

  static const _chartColors = [
    Color(0xFF0E7490),
    Color(0xFF14B8A6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF3B82F6),
    Color(0xFF6366F1),
    Color(0xFFF97316),
  ];

  @override
  Widget build(BuildContext context) {
    if (chartData.data.isEmpty) {
      return const Text('No data');
    }

    final maxValue = chartData.data
        .map((d) => d.value)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chartData.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: ${chartData.currencySymbol ?? ''}${chartData.data.fold<double>(0, (sum, d) => sum + d.value).toStringAsFixed(2)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: _buildChart(maxValue)),
        ],
      ),
    );
  }

  Widget _buildChart(double maxValue) {
    switch (chartData.type) {
      case 'pie':
        return _buildPieChart();
      case 'line':
        return _buildLineChart(maxValue);
      default:
        return _buildBarChart(maxValue);
    }
  }

  Widget _buildBarChart(double maxValue) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final point = chartData.data[groupIndex];
              return BarTooltipItem(
                '${point.label}\n${chartData.currencySymbol ?? ''}${point.value.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartData.data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      chartData.data[index].label.length > 5
                          ? '${chartData.data[index].label.substring(0, 5)}...'
                          : chartData.data[index].label,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${chartData.currencySymbol ?? ''}${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartData.data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                color: _chartColors[entry.key % _chartColors.length],
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart(double maxValue) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 &&
                    index < chartData.data.length &&
                    index % 2 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      chartData.data[index].label.length > 5
                          ? chartData.data[index].label.substring(0, 5)
                          : chartData.data[index].label,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${chartData.currencySymbol ?? ''}${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxValue * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: chartData.data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: _chartColors[0],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: _chartColors[0],
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: _chartColors[0].withValues(alpha: 0.15),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < chartData.data.length) {
                  final point = chartData.data[index];
                  return LineTooltipItem(
                    '${point.label}\n${chartData.currencySymbol ?? ''}${point.value.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final total = chartData.data.fold<double>(0, (sum, d) => sum + d.value);

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: chartData.data.asMap().entries.map((entry) {
                final percentage =
                    total > 0 ? (entry.value.value / total * 100) : 0;
                return PieChartSectionData(
                  color: _chartColors[entry.key % _chartColors.length],
                  value: entry.value.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: chartData.data.asMap().entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _chartColors[entry.key % _chartColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  entry.value.label.length > 10
                      ? '${entry.value.label.substring(0, 10)}...'
                      : entry.value.label,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

