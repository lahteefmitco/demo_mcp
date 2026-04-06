import 'package:flutter/material.dart';

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
              'Hi, I can help you analyze spending, list expenses, and create new expense entries. Ask me to show charts like "show me today\'s expenses in a bar chart" or "show weekly expenses in line chart".',
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

  ChatChartData? _parseChartRequest(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('chart') || lowerText.contains('graph')) {
      String chartType = 'bar';
      if (lowerText.contains('line')) {
        chartType = 'line';
      } else if (lowerText.contains('pie')) {
        chartType = 'pie';
      }

      if (lowerText.contains('today') || lowerText.contains("today's")) {
        return ChatChartData(
          type: chartType,
          title: "Today's Expenses",
          data: [],
        );
      } else if (lowerText.contains('week') || lowerText.contains('weekly')) {
        return ChatChartData(
          type: chartType,
          title: 'Weekly Expenses',
          data: [],
        );
      } else if (lowerText.contains('month') || lowerText.contains('monthly')) {
        return ChatChartData(
          type: chartType,
          title: 'Monthly Expenses',
          data: [],
        );
      }
    }
    return null;
  }

  Future<ChatChartData?> _fetchChartData(ChatChartData chartRequest) async {
    final chartData = chartRequest;
    final currencySymbol = widget.currency.symbol;

    if (chartData.title.contains("Today")) {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final expenses = await _financeClient.listExpenses(
        from: todayStr,
        to: todayStr,
      );

      final Map<String, double> categoryTotals = {};
      for (final expense in expenses) {
        categoryTotals[expense.categoryName] =
            (categoryTotals[expense.categoryName] ?? 0) + expense.amount;
      }

      final dataPoints = categoryTotals.entries
          .map((e) => ChartDataPoint(label: e.key, value: e.value))
          .toList();

      return ChatChartData(
        type: chartData.type,
        title: "Today's Expenses",
        data: dataPoints,
        currencySymbol: currencySymbol,
      );
    } else if (chartData.title.contains('Weekly')) {
      final expenses = await _financeClient.fetchDailyExpenses(days: 7);
      final dataPoints = expenses
          .map((e) => ChartDataPoint(label: e.dayName, value: e.total))
          .toList();

      return ChatChartData(
        type: chartData.type,
        title: 'Weekly Expenses',
        data: dataPoints,
        currencySymbol: currencySymbol,
      );
    } else if (chartData.title.contains('Monthly')) {
      final expenses = await _financeClient.fetchMonthlyExpenses(months: 6);
      final dataPoints = expenses
          .map((e) => ChartDataPoint(label: e.monthName, value: e.total))
          .toList();

      return ChatChartData(
        type: chartData.type,
        title: 'Monthly Expenses',
        data: dataPoints,
        currencySymbol: currencySymbol,
      );
    }

    return null;
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

    final chartRequest = _parseChartRequest(text);
    ChatChartData? chartData;

    if (chartRequest != null) {
      chartData = await _fetchChartData(chartRequest);
    }

    setState(() {
      _messages.add(ChatMessageData(role: 'user', content: text));
      if (chartData != null && chartData.data.isNotEmpty) {
        _messages.add(
          ChatMessageData(role: 'assistant', content: '', chartData: chartData),
        );
      }
      _controller.clear();
      _isSending = true;
    });

    await _database.addMessage(_currentSessionId!, 'user', text);

    if (chartData == null || chartData.data.isEmpty) {
      try {
        final reply = await _chatApi.sendMessage(
          _messages
              .map((m) => ChatMessage(role: m.role, content: m.content))
              .toList(),
          provider: _selectedProvider,
        );
        if (!mounted) {
          return;
        }

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
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } else {
      final replyText = chartData.data.isNotEmpty
          ? 'Here\'s the ${chartData.title.toLowerCase()} chart:'
          : 'No expenses found for the requested period.';

      setState(() {
        if (_messages.last.chartData == null) {
          _messages.add(ChatMessageData(role: 'assistant', content: replyText));
        } else {
          _messages[_messages.length - 1] = ChatMessageData(
            role: 'assistant',
            content: replyText,
            chartData: chartData,
          );
        }
      });

      await _database.addMessage(_currentSessionId!, 'assistant', replyText);
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
                                _ChatChart(chartData: message.chartData!),
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
                      hintText: 'Ask like: show weekly expenses in bar chart',
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

class _ChatChart extends StatelessWidget {
  const _ChatChart({required this.chartData});

  final ChatChartData chartData;

  @override
  Widget build(BuildContext context) {
    if (chartData.data.isEmpty) {
      return const Text('No data available');
    }

    final maxValue = chartData.data
        .map((d) => d.value)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            chartData.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (chartData.type == 'bar')
            _BarChart(
              data: chartData.data,
              maxValue: maxValue,
              currencySymbol: chartData.currencySymbol,
            )
          else if (chartData.type == 'line')
            _LineChart(
              data: chartData.data,
              maxValue: maxValue,
              currencySymbol: chartData.currencySymbol,
            )
          else
            _PieChart(
              data: chartData.data,
              currencySymbol: chartData.currencySymbol,
            ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.data,
    required this.maxValue,
    this.currencySymbol,
  });

  final List<ChartDataPoint> data;
  final double maxValue;
  final String? currencySymbol;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF0E7490),
      const Color(0xFF14B8A6),
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF3B82F6),
    ];

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final point = entry.value;
          final barHeight = maxValue > 0 ? (point.value / maxValue) * 120 : 0.0;
          final color = colors[index % colors.length];

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (point.value > 0)
                    Text(
                      '${currencySymbol ?? ''}${point.value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 8,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Container(
                    height: barHeight > 0 ? barHeight : 3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    point.label.length > 5
                        ? '${point.label.substring(0, 5)}...'
                        : point.label,
                    style: const TextStyle(fontSize: 8),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.data,
    required this.maxValue,
    this.currencySymbol,
  });

  final List<ChartDataPoint> data;
  final double maxValue;
  final String? currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return _BarChart(
        data: data,
        maxValue: maxValue,
        currencySymbol: currencySymbol,
      );
    }

    final colors = [
      const Color(0xFF0E7490),
      const Color(0xFF14B8A6),
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];

    return SizedBox(
      height: 150,
      child: CustomPaint(
        size: const Size(260, 130),
        painter: _LineChartPainter(
          data: data,
          maxValue: maxValue,
          color: colors[0],
          currencySymbol: currencySymbol,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double maxValue;
  final Color color;
  final String? currencySymbol;

  _LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.color,
    this.currencySymbol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final points = <Offset>[];
    final spacing = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * spacing;
      final y =
          size.height -
          (maxValue > 0 ? (data[i].value / maxValue) * size.height : 0);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);

    final linePath = Path();
    if (points.isNotEmpty) {
      linePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(linePath, paint);

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }

    for (int i = 0; i < data.length; i++) {
      textPainter.text = TextSpan(
        text: data[i].label.length > 4
            ? '${data[i].label.substring(0, 4)}...'
            : data[i].label,
        style: const TextStyle(fontSize: 8, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2, size.height + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PieChart extends StatelessWidget {
  const _PieChart({required this.data, this.currencySymbol});

  final List<ChartDataPoint> data;
  final String? currencySymbol;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    final colors = [
      const Color(0xFF0E7490),
      const Color(0xFF14B8A6),
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF3B82F6),
    ];

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: CustomPaint(
            size: const Size(120, 120),
            painter: _PieChartPainter(data: data, colors: colors),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: data.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final percentage = total > 0 ? (point.value / total * 100) : 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${point.label}: ${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final List<Color> colors;

  _PieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    double startAngle = -3.14159 / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * 3.14159;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
