import 'package:logger/logger.dart';

final logger = Logger(
  level: Level.debug,
  printer: PrettyPrinter(
    methodCount: 2, // no. of method calls to be called
    errorMethodCount: 8, // methods for stacktrace
    lineLength: 120, // output width
    colors: true, // colorful messages
    printEmojis: true, // print emoji for each log message
    // timestamp each log print
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
