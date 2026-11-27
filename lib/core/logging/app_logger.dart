import 'package:logger/logger.dart';

/// Application-wide logger instance.
///
/// Uses the `logger` package for structured, leveled logging.
/// In production, this can be configured to output to a file or remote service.
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTime,
  ),
  level: Level.info,
);