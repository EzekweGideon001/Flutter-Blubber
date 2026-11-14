import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'error_report_service.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Stream audio directly from the provided remote URL
  Future<bool> playAudio(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return false;
    }

    try {
      await _audioPlayer.stop();

      final Completer<bool> completer = Completer<bool>();
      StreamSubscription? stateSub;

      // Listen for player state changes to confirm actual playback
      stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.playing) {
          if (!completer.isCompleted) completer.complete(true);
          stateSub?.cancel();
        }
      }, onError: (Object error, StackTrace stackTrace) {
        ErrorReportService.recordError(
          context: 'audio.player_state',
          error: error,
          stackTrace: stackTrace,
        );
        if (!completer.isCompleted) completer.complete(false);
        stateSub?.cancel();
      });

      await _audioPlayer.play(UrlSource(url.trim()));

      // Timeout after 3 seconds if the audio stream fails to respond
      return await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () async {
          ErrorReportService.recordError(
            context: 'audio.playback_timeout',
            error: TimeoutException('Audio playback did not start'),
            stackTrace: StackTrace.current,
          );
          stateSub?.cancel();
          await _audioPlayer.stop();
          return false;
        },
      );
    } catch (error, stackTrace) {
      ErrorReportService.recordError(
        context: 'audio.playback',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}