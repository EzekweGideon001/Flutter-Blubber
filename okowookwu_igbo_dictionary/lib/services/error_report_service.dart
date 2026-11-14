import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Keeps bounded diagnostic reports in private app storage; reports are never
/// transmitted.
abstract final class ErrorReportService {
  static const _fileName = 'diagnostic-report.log';
  static const _maxFileBytes = 512 * 1024;
  static Future<void> _writeQueue = Future<void>.value();

  static void recordError({
    required String context,
    required Object error,
    StackTrace? stackTrace,
  }) {
    final entry = _formatEntry(context, error, stackTrace);
    _writeQueue = _writeQueue.then((_) => _appendEntry(entry)).catchError((
      Object writeError,
      StackTrace writeStackTrace,
    ) {
      developer.log(
        'Unable to save the local diagnostic report',
        name: 'ErrorReportService',
        error: writeError,
        stackTrace: writeStackTrace,
      );
    });
  }

  static String _formatEntry(
    String context,
    Object error,
    StackTrace? stackTrace,
  ) {
    final safeMessage = error
        .toString()
        .replaceAll(RegExp(r'https?://[^\s]+'), '[URL]')
        .replaceAllMapped(
          RegExp(r'\b(keyword|query|word)=([^&\s]+)', caseSensitive: false),
          (match) => '${match[1]}=[REDACTED]',
        )
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .trim();

    return 'time=${DateTime.now().toUtc().toIso8601String()}\n'
        'context=$context\n'
        'type=${error.runtimeType}\n'
        'message=${safeMessage.substring(0, safeMessage.length.clamp(0, 1000))}\n'
        'stack=${stackTrace ?? StackTrace.current}\n'
        '---\n';
  }

  static Future<void> _appendEntry(String entry) async {
    final directory = await getApplicationSupportDirectory();
    final file = File(path.join(directory.path, _fileName));
    final entryLength = utf8.encode(entry).length;

    if (await file.exists() &&
        await file.length() + entryLength > _maxFileBytes) {
      final previousFile = File('${file.path}.1');
      if (await previousFile.exists()) await previousFile.delete();
      await file.rename(previousFile.path);
    }

    await file.writeAsString(entry, mode: FileMode.append, flush: true);
  }
}
