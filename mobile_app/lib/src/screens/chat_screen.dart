import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../api/chat_api.dart';
import '../api/finance_mcp_client.dart';
import '../database/chat_database.dart';
import '../models/auth_session.dart';
import '../models/chat_message.dart';
import '../models/currency_option.dart';
import '../settings/app_preferences_storage.dart';

class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({required this.label, required this.value});
}

class ChatChartData {
  final String type;
  final String title;
  final List<ChartDataPoint> data;
  final String? currencySymbol;

  ChatChartData({
    required this.type,
    required this.title,
    required this.data,
    this.currencySymbol,
  });
}

class ChatMessageData {
  final String role;
  final String content;
  final ChatChartData? chartData;

  ChatMessageData({required this.role, required this.content, this.chartData});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.session,
    required this.currency,
    required this.onOpenProfile,
    super.key,
  });

  final AuthSession session;
  final CurrencyOption currency;
  final Future<void> Function() onOpenProfile;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatApi _chatApi;
  late final FinanceMcpClient _financeClient;
  late final ChatDatabase _database;
  final AppPreferencesStorage _preferencesStorage = AppPreferencesStorage();
  final TextEditingController _controller = TextEditingController();
  static const _providers = <String, String>{
    'gemini': 'Gemini',
    'mistral': 'Mistral',
    'openrouter': 'OpenRouter',
  };
  static const _defaultProvider = 'gemini';
  List<ChatMessageData> _messages = [];
  bool _isSending = false;
  String _selectedProvider = _defaultProvider;
  int? _currentSessionId;
  bool _isLoadingSessions = false;

  @override
  void initState() {
    super.initState();
    _chatApi = ChatApi(token: widget.session.token);
    _financeClient = FinanceMcpClient(token: widget.session.token);
    _database = ChatDatabase();
    _restoreSelectedProvider();
    _loadSessions();
    _startNewSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    _database.close();
    super.dispose();
  }

  Future<void> _loadSessions() async {}

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

  void _startNewSession() {
    _currentSessionId = null;
    setState(() {
      _messages = [
        ChatMessageData(
          role: 'assistant',
          content:
              'Hi, I can help you analyze spending, list expenses, and create new expense entries. Ask me to show charts like "show me today\'s expenses in bar chart" or "show weekly expenses in line chart" or "show expenses by category as pie chart".',
        ),
      ];
    });
  }

  Future<void> _loadSession(ChatSessionData session) async {
    setState(() {
      _isLoadingSessions = true;
    });

    final messages = await _database.getMessagesForSession(session.id);
    setState(() {
      _currentSessionId = session.id;
      _selectedProvider = session.model;
      _messages = messages
          .map((m) => ChatMessageData(role: m.role, content: m.content))
          .toList();
      _isLoadingSessions = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String? _detectChartPeriod(String text) {
    final lower = text.toLowerCase();

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
    if (period == null) return null;

    final type = _detectChartType(text);

    try {
      final chartData = await _financeClient.fetchChartData(
        type: type,
        period: period,
      );

      if (chartData.data.isEmpty) {
        return null;
      }

      return ChatChartData(
        type: chartData.type,
        title: chartData.title,
        data: chartData.data
            .map((d) => ChartDataPoint(label: d.label, value: d.value))
            .toList(),
        currencySymbol: widget.currency.symbol,
      );
    } catch (e) {
      debugPrint('Error fetching chart: $e');
      return null;
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    if (_currentSessionId == null) {
      _currentSessionId = await _database.createSession(_selectedProvider);
      await _loadSessions();
    }

    final isChart = _isChartRequest(text);
    ChatChartData? chartData;

    if (isChart) {
      chartData = await _fetchChartFromBackend(text);
    }

    setState(() {
      _messages.add(ChatMessageData(role: 'user', content: text));
      if (chartData != null) {
        _messages.add(
          ChatMessageData(
            role: 'assistant',
            content: chartData.title,
            chartData: chartData,
          ),
        );
      }
      _controller.clear();
      _isSending = true;
    });

    await _database.addMessage(_currentSessionId!, 'user', text);

    if (chartData == null && isChart) {
      setState(() {
        _messages.add(
          ChatMessageData(
            role: 'assistant',
            content: 'No expense data found for the requested period.',
          ),
        );
      });
      await _database.addMessage(
        _currentSessionId!,
        'assistant',
        'No expense data found.',
      );
    } else if (chartData == null) {
      try {
        final reply = await _chatApi.sendMessage(
          _messages
              .where((m) => m.chartData == null)
              .map((m) => ChatMessage(role: m.role, content: m.content))
              .toList(),
          provider: _selectedProvider,
        );
        if (!mounted) return;

        final replyContent = reply.isEmpty ? 'Done.' : reply;
        setState(() {
          _messages.add(
            ChatMessageData(role: 'assistant', content: replyContent),
          );
        });
        await _database.addMessage(
          _currentSessionId!,
          'assistant',
          replyContent,
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } else {
      await _database.addMessage(
        _currentSessionId!,
        'assistant',
        chartData.title,
      );
    }

    if (mounted) {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showChatHistory() async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (sheetContext, scrollController) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              return FutureBuilder<List<ChatSessionData>>(
                future: _database.getAllSessions(),
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
                                _startNewSession();
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
                        child:
                            snapshot.connectionState == ConnectionState.waiting
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
                                      backgroundColor: const Color(
                                        0xFF0E7490,
                                      ).withValues(alpha: 0.1),
                                      child: Text(
                                        _providers[session.model]?.substring(
                                              0,
                                              1,
                                            ) ??
                                            'C',
                                        style: const TextStyle(
                                          color: Color(0xFF0E7490),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      _providers[session.model] ??
                                          session.model,
                                    ),
                                    subtitle: Text(
                                      '${_formatDate(session.createdAt)} - Session #${session.id}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        await _database.deleteSession(
                                          session.id,
                                        );
                                        setSheetState(() {});
                                      },
                                    ),
                                    onTap: () async {
                                      await _loadSession(session);
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
            onPressed: _showChatHistory,
            icon: const Icon(Icons.history),
            tooltip: 'Chat History',
          ),
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
            child: _isLoadingSessions
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
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
                            color: isUser
                                ? const Color(0xFF0E7490)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message.content.isNotEmpty)
                                Text(
                                  message.content,
                                  style: TextStyle(
                                    color: isUser
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              if (message.chartData != null &&
                                  message.chartData!.data.isNotEmpty) ...[
                                if (message.content.isNotEmpty)
                                  const SizedBox(height: 12),
                                _ExpenseChart(chartData: message.chartData!),
                              ],
                            ],
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
                      hintText: 'Ask: show weekly expenses in bar chart',
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
                final percentage = total > 0
                    ? (entry.value.value / total * 100)
                    : 0;
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
