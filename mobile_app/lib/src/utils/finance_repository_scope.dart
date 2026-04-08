import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/finance_repository.dart';

/// Overlay routes are not under [AppShell]'s [RepositoryProvider]. Call this
/// from a [BuildContext] that already has [FinanceRepository] (e.g. a shell tab).
Future<T?> pushRouteWithFinanceRepository<T extends Object?>(
  BuildContext context,
  Widget screen,
) {
  final repo = context.read<FinanceRepository>();
  return Navigator.of(context).push<T>(
    MaterialPageRoute<T>(
      builder: (_) => RepositoryProvider<FinanceRepository>.value(
        value: repo,
        child: screen,
      ),
    ),
  );
}
