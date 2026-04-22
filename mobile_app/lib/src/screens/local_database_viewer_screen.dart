import 'package:flutter/material.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';

import '../database/finance_database_holder.dart';

/// Debug screen for inspecting the local Drift finance database.
class LocalDatabaseViewerScreen extends StatelessWidget {
  const LocalDatabaseViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Local database')),
      body: DriftDbViewer(FinanceDatabaseHolder.instance),
    );
  }
}
