import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/providers/styles_provider.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:styled_text/styled_text.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  final player = AudioPlayer();
  Stream<DurationState>? durationState;

  void init(String url) async {
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
    } on PlayerInterruptedException catch (e) {
      // This call was interrupted since another audio source was loaded or the
      // player was stopped or disposed before this audio source could complete
      // loading.
      ShowSnackBar.showSnackBar("Connection aborted: ${e.message}");
    } catch (e) {
      // Fallback for all other errors
      ShowSnackBar.showSnackBar('An error occured: $e');
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

class DialogBox extends StatelessWidget {
  final String? title;
  final String body;
  const DialogBox({super.key, this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    bool combineWithTheme = context.select<UiProvider, bool>((p) => p.combineWithTheme);
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10.0, left: 4.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            boxShadow: [
              const BoxShadow(
                color: Color(0x80000000),
                blurStyle: BlurStyle.outer,
                blurRadius: 12.0,
              ),
            ],
            color: combineWithTheme
                ? Color.lerp(
                    Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(166, 85, 85, 85)
                        : const Color.fromARGB(166, 0, 0, 0),
                    Theme.of(context).colorScheme.primaryContainer,
                    0.35,
                  )
                : Theme.of(context).brightness == Brightness.light
                    ? const Color.fromARGB(166, 85, 85, 85)
                    : const Color(0xa6000000),
          ),
          child: StyledText(
            text: body,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Noto Sans',
              fontWeight: FontWeight.w700,
            ),
            tags: context.read<StyleProvider>().tagsAsHtml(context: context),
            async: true,
          ),
        ),
        title != null
            ? Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 8.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF9e9e9e),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x80000000),
                        offset: Offset(0, 3),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Text(
                    title!.padRight(36),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class InkWellDialogBox extends StatelessWidget {
  final String? title;
  final String body;
  final Function()? inkwellFun;
  const InkWellDialogBox({
    super.key,
    this.title,
    required this.body,
    this.inkwellFun,
  });

  @override
  Widget build(BuildContext context) {
    bool combineWithTheme = context.select<UiProvider, bool>((p) => p.combineWithTheme);
    return Stack(
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10.0, left: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              width: double.maxFinite,
              decoration: BoxDecoration(
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x80000000),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 12.0,
                  ),
                ],
                color: combineWithTheme
                    ? Color.lerp(
                        Theme.of(context).brightness == Brightness.light
                            ? const Color.fromARGB(166, 85, 85, 85)
                            : const Color.fromARGB(166, 0, 0, 0),
                        Theme.of(context).colorScheme.primaryContainer,
                        0.65,
                      )
                    : Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(166, 85, 85, 85)
                        : const Color(0xa6000000),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StyledText(
                      text: body,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Noto Sans',
                        fontWeight: FontWeight.w700,
                      ),
                      tags: context.read<StyleProvider>().tagsAsHtml(context: context),
                      async: true,
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            title != null
                ? Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 8.0,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF9e9e9e),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x80000000),
                            offset: Offset(0, 3),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      // ignore: deprecated_member_use
                      child: Text(
                        title!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaler: title!.length > 42
                            ? TextScaler.linear(
                                // ignore: deprecated_member_use
                                MediaQuery.textScalerOf(context).textScaleFactor -
                                    ((title!.length - 42) / 100),
                              )
                            : null,
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: inkwellFun,
            ),
          ),
        ),
      ],
    );
  }
}

class AudioDialogBox extends StatelessWidget {
  final String? title;
  final String body;
  final Function()? fun;
  final bool isPlaying;
  final AudioPlayerManager manager;
  const AudioDialogBox({
    super.key,
    this.title,
    required this.body,
    this.fun,
    this.isPlaying = false,
    required this.manager,
  });

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: manager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          buffered: buffered,
          total: total,
          onSeek: manager.player.seek,
          onDragUpdate: (details) {},
          timeLabelLocation: TimeLabelLocation.none,
          barCapShape: BarCapShape.square,
          baseBarColor: Theme.of(context).colorScheme.surface,
          progressBarColor: Theme.of(context).colorScheme.secondary,
          barHeight: 4.0,
          thumbRadius: 6.0,
          thumbColor: Theme.of(context).colorScheme.primary,
          thumbGlowRadius: 15,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool combineWithTheme = context.select<UiProvider, bool>((p) => p.combineWithTheme);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10.0, left: 4.0, bottom: 8.0),
          width: double.maxFinite,
          decoration: BoxDecoration(
            boxShadow: [
              const BoxShadow(
                color: Color(0x80000000),
                blurStyle: BlurStyle.outer,
                blurRadius: 12.0,
              ),
            ],
            color: combineWithTheme
                ? Color.lerp(
                    Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(166, 85, 85, 85)
                        : const Color.fromARGB(166, 0, 0, 0),
                    Theme.of(context).colorScheme.primaryContainer,
                    0.35,
                  )
                : Theme.of(context).brightness == Brightness.light
                    ? const Color.fromARGB(166, 85, 85, 85)
                    : const Color(0xa6000000),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: isPlaying
                          ? const EdgeInsets.fromLTRB(16.0, 16.0, 0, 16.0)
                          : const EdgeInsets.all(16.0),
                      child: StyledText(
                        text: body,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Noto Sans',
                          fontWeight: FontWeight.w700,
                        ),
                        tags: context.read<StyleProvider>().tagsAsHtml(context: context),
                        async: true,
                      ),
                    ),
                  ),
                  isPlaying
                      ? Expanded(
                          flex: 2,
                          child: Center(
                            child: StreamBuilder<PlayerState>(
                              stream: manager.player.playerStateStream,
                              builder: (context, snapshot) {
                                final playerState = snapshot.data;
                                final processingState = playerState?.processingState;
                                final playing = playerState?.playing;
                                if (processingState == ProcessingState.loading ||
                                    processingState == ProcessingState.buffering) {
                                  return SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                } else if (playing != true) {
                                  return Icon(
                                    Icons.play_arrow,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 32,
                                  );
                                } else if (processingState != ProcessingState.completed) {
                                  return Icon(
                                    Icons.pause,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 32,
                                  );
                                } else {
                                  return Icon(
                                    Icons.replay,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 32,
                                  );
                                }
                              },
                            ),
                          ),
                        )
                      : null,
                ].nullParser(),
              ),
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: fun,
                  ),
                ),
              ),
            ],
          ),
        ),
        title != null
            ? Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 8.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF9e9e9e),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x80000000),
                        offset: Offset(0, 3),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Text(
                    title!.padRight(36),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
        isPlaying
            ? Positioned(
                bottom: 2.0,
                right: 0,
                left: 4.0,
                child: _progressBar(),
              )
            : null,
      ].nullParser(),
    );
  }
}
