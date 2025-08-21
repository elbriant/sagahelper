import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sagahelper/core/snack_bar_service.dart';

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration? total;
}

class AudioPlayerManager {
  final player = AudioPlayer();
  Stream<DurationState>? durationState;

  void init(String url, [String? fallbackUrl]) async {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );
    try {
      await player.setUrl(url);
      player.play();
    } on PlayerException {
      if (fallbackUrl != null) {
        await player.setUrl(fallbackUrl);
        player.play();
        SnackBarService.showSnackBar(
          "Audio source doesn't exist for selected language, fallback to japanese",
        );
      } else {
        rethrow;
      }
    } on PlayerInterruptedException {
      // ignore interrumptions
    } on PlatformException {
      // ignore interrumptions
    } catch (e) {
      // Fallback for all other errors
      SnackBarService.showSnackBar('An error occured: $e');
    }
  }

  void play() {
    player.play();
  }

  void pause() {
    player.pause();
  }

  void stop() {
    player.stop();
  }

  void dispose() async {
    await player.stop();
    player.dispose();
  }
}
