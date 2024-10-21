import 'package:just_audio/just_audio.dart';
import 'package:sagahelper/components/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/components/utils.dart';
import 'package:sagahelper/pages/operator_info.dart';
import 'package:styled_text/widgets/styled_text.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

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
  final bool combineWithTheme;
  const DialogBox({super.key, this.title, required this.body, this.combineWithTheme = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10.0, left: 4.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0x80000000),
                blurStyle: BlurStyle.outer,
                blurRadius: 12.0
              )
            ],
            color: combineWithTheme ? Color.lerp(Color(0xa6000000), Theme.of(context).colorScheme.primary, 0.35) : Color(0xa6000000)
          ),
          child: StyledText(
            text: body,
            style: TextStyle(color: Colors.white, fontFamily: 'Noto Sans', fontWeight: FontWeight.w700),
            tags: tagsAsHtml,
          )
        ),
        title != null ? Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF9e9e9e),
              boxShadow: [
                BoxShadow(
                color: const Color(0x80000000),
                offset: Offset(0, 3),
                blurRadius: 6.0
              )
              ],
            ),
            child: Text(title!.padRight(36), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), ),
          )
        ) : SizedBox()
      ],
    );
  }
}

class InkWellDialogBox extends StatelessWidget {
  final String? title;
  final String body;
  final bool combineWithTheme;
  final Function()? inkwellFun;
  const InkWellDialogBox({super.key, this.title, required this.body, this.inkwellFun, this.combineWithTheme = true});

  @override
  Widget build(BuildContext context) {
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
                  BoxShadow(
                    color: const Color(0x80000000),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 12.0
                  )
                ],
                color: combineWithTheme ? Color.lerp(Color(0xa6000000), Theme.of(context).colorScheme.primary, 0.65) : Color(0xa6000000)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StyledText(
                      text: body,
                      style: TextStyle(color: Colors.white, fontFamily: 'Noto Sans', fontWeight: FontWeight.w700),
                      tags: tagsAsHtml,
                    ),
                  ),
                  Center(
                      child: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.secondaryContainer, size: 32)
                    ),
                ],
              )
            ),
            title != null ? Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF9e9e9e),
                  boxShadow: [
                    BoxShadow(
                    color: const Color(0x80000000),
                    offset: Offset(0, 3),
                    blurRadius: 6.0
                  )
                  ],
                ),
                child: Text(title!, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              )
            ) : SizedBox()
            
          ],
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: inkwellFun,
            ),
          ),
        )
      ],
    );
  }
}

class AudioDialogBox extends StatelessWidget {
  final String? title;
  final String body;
  final bool combineWithTheme;
  final Function()? fun;
  final bool isPlaying;
  final AudioPlayerManager manager;
  const AudioDialogBox({super.key, this.title, required this.body, this.combineWithTheme = true, this.fun, this.isPlaying = false, required this.manager});

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
          onDragUpdate: (details) {
            print('${details.timeStamp}, ${details.localPosition}');
          },
          timeLabelLocation: TimeLabelLocation.none,
          barCapShape: BarCapShape.square,
          baseBarColor: Theme.of(context).colorScheme.surface,
          progressBarColor: Theme.of(context).colorScheme.primary,
          barHeight: 4.0,
          thumbRadius: 6.0,
          thumbColor: Theme.of(context).colorScheme.secondary,
          thumbGlowRadius: 15,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10.0, left: 4.0, bottom: 8.0),
          width: double.maxFinite,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0x80000000),
                blurStyle: BlurStyle.outer,
                blurRadius: 12.0
              )
            ],
            color: combineWithTheme ? Color.lerp(Color(0xa6000000), Theme.of(context).colorScheme.primary, 0.35) : Color(0xa6000000)
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: isPlaying? const EdgeInsets.fromLTRB(16.0, 16.0, 0, 16.0) : const EdgeInsets.all(16.0),
                      child: StyledText(
                        text: body,
                        style: TextStyle(color: Colors.white, fontFamily: 'Noto Sans', fontWeight: FontWeight.w700),
                        tags: tagsAsHtml,
                      ),
                    ),
                  ),
                  isPlaying? Expanded(
                    flex: 2,
                    child: Center(
                      child: StreamBuilder<PlayerState>(
                        stream: manager.player.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                            return SizedBox.square(dimension: 24, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary));
                          } else if (playing != true) {
                            return Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.tertiary, size: 32);
                          } else if (processingState != ProcessingState.completed) {
                            return Icon(Icons.pause, color: Theme.of(context).colorScheme.tertiary, size: 32);
                          } else {
                            return Icon(Icons.replay, color: Theme.of(context).colorScheme.tertiary, size: 32);
                          }
                        },
                      )
                    ),
                  ) : null
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
          )
        ),
        title != null ? Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF9e9e9e),
              boxShadow: [
                BoxShadow(
                color: const Color(0x80000000),
                offset: Offset(0, 3),
                blurRadius: 6.0
              )
              ],
            ),
            child: Text(title!.padRight(36), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ) : SizedBox(),
        isPlaying? Positioned(
          bottom: 0,
          right: 0,
          left: 4.0,
          child:  _progressBar()
        ) : null,
      ].nullParser(),
    );
  }
}