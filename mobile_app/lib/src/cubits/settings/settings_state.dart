import '../../models/finance_models.dart';
import '../../models/mcp_tool.dart';

class SettingsState {
  const SettingsState({
    required this.future,
    required this.toastNonce,
    required this.toastMessage,
    required this.toastIsError,
  });

  final Future<SettingsData> future;

  /// One-shot toast event.
  final int toastNonce;
  final String? toastMessage;
  final bool toastIsError;

  SettingsState copyWith({
    Future<SettingsData>? future,
    int? toastNonce,
    String? toastMessage,
    bool? toastIsError,
  }) {
    return SettingsState(
      future: future ?? this.future,
      toastNonce: toastNonce ?? this.toastNonce,
      toastMessage: toastMessage,
      toastIsError: toastIsError ?? this.toastIsError,
    );
  }
}

class SettingsData {
  const SettingsData({required this.dashboard, required this.tools});

  final FinanceDashboard dashboard;
  final List<McpTool> tools;
}
