import 'dart:io';

import 'package:logging/logging.dart';

/// Initializes the logger for the application.
void initLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(
    (record) {
      final time = record.time.toIso8601String();
      final level = record.level.name;
      final loggerName = record.loggerName;
      final message = record.message;
      stdout.writeln('[$time] [$level] [$loggerName]: $message');
    },
  );
}
