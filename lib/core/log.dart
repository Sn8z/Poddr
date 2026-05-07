import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { debug, info, warning, error }

const String _logFileName = 'poddr.log';
const String _oldLogFileName = 'poddr.log.old';
const int _maxFileSizeBytes = 5 * 1024 * 1024;

File? _logFile;
bool _initialized = false;

Future<void> _init() async {
  if (_initialized) return;
  try {
    final dir = await getApplicationSupportDirectory();
    final logDir = Directory('${dir.path}/logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    _logFile = File('${logDir.path}/$_logFileName');
    await _checkRotation();
    _initialized = true;
  } catch (e) {
    developer.log('Failed to initialize logger: $e', name: 'PoddrLog');
  }
}

Future<void> _checkRotation() async {
  if (_logFile == null) return;
  try {
    if (await _logFile!.exists()) {
      final size = await _logFile!.length();
      if (size > _maxFileSizeBytes) {
        final oldPath = '${_logFile!.parent.path}/$_oldLogFileName';
        final oldFile = File(oldPath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
        await _logFile!.rename(oldPath);
        _logFile = File('${_logFile!.parent.path}/$_logFileName');
      }
    }
  } catch (e) {
    developer.log('Failed to rotate log file: $e', name: 'PoddrLog');
  }
}

Future<void> _writeToFile(String message) async {
  if (_logFile == null) return;
  try {
    await _logFile!.writeAsString('$message\n', mode: FileMode.append);
  } catch (e) {
    developer.log('Failed to write to log file: $e', name: 'PoddrLog');
  }
}

void _log(LogLevel level, String message,
    {String? name, Object? error, StackTrace? stackTrace}) {
  final timestamp = DateTime.now().toIso8601String();
  final levelStr = level.name.toUpperCase();
  final nameStr = name != null ? '[$name]' : '';
  final formatted = '[$timestamp] [$levelStr]$nameStr $message';

  if (kReleaseMode && level == LogLevel.debug) {
    return;
  }

  developer.log(message,
      name: name ?? 'Poddr', error: error, stackTrace: stackTrace);

  if (level != LogLevel.debug) {
    _init().then((_) => _writeToFile(formatted));
  }

  if (error != null && stackTrace != null && level == LogLevel.error) {
    final errorMsg = '[$timestamp] [ERROR][$name] Error: $error\n$stackTrace';
    _init().then((_) => _writeToFile(errorMsg));
  }
}

void debug(String message, {String? name}) {
  _log(LogLevel.debug, message, name: name);
}

void info(String message, {String? name}) {
  _log(LogLevel.info, message, name: name);
}

void warning(String message, {String? name}) {
  _log(LogLevel.warning, message, name: name);
}

void error(String message,
    {String? name, Object? error, StackTrace? stackTrace}) {
  _log(LogLevel.error, message,
      name: name, error: error, stackTrace: stackTrace);
}

Future<String?> exportLogs() async {
  await _init();
  if (_logFile == null || !await _logFile!.exists()) {
    return null;
  }
  try {
    return await _logFile!.readAsString();
  } catch (e) {
    developer.log('Failed to export logs: $e', name: 'PoddrLog');
    return null;
  }
}

Future<void> clearLogs() async {
  await _init();
  if (_logFile != null && await _logFile!.exists()) {
    await _logFile!.delete();
  }
  final oldPath = '${_logFile?.parent.path}/$_oldLogFileName';
  final oldFile = File(oldPath);
  if (await oldFile.exists()) {
    await oldFile.delete();
  }
}
