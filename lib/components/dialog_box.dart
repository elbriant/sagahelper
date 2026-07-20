import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/core/notification_service.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';
import 'package:sagahelper/providers/connectivity_provider.dart';
import 'package:sagahelper/providers/style_provider.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/utils/audio_player_manager.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'dart:developer' as dev;

class DialogBox extends ConsumerWidget {
  final String? title;
  final String body;
  const DialogBox({super.key, this.title, required this.body});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useClassicDialogBox =
        ref.watch(configProvider.select((p) => p.useClassicDialogBox));
    final tagsAsArknights = ref.watch(styleProvider).tagsAsHtml;

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
            color: useClassicDialogBox
                ? const Color.fromARGB(190, 85, 85, 85)
                : Color.lerp(
                    Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(166, 85, 85, 85)
                        : const Color.fromARGB(166, 0, 0, 0),
                    Theme.of(context).colorScheme.primaryContainer,
                    0.35,
                  ),
          ),
          child: StyledText(
            text: body,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Noto Sans',
              fontWeight: FontWeight.w700,
            ),
            tags: tagsAsArknights,
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

class InkWellDialogBox extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final useClassicDialogBox =
        ref.watch(configProvider.select((p) => p.useClassicDialogBox));
    final tagsAsArknights = ref.watch(styleProvider).tagsAsHtml;

    return Stack(
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10.0, left: 4.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              width: double.maxFinite,
              decoration: BoxDecoration(
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x80000000),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 12.0,
                  ),
                ],
                color: useClassicDialogBox
                    ? const Color.fromARGB(255, 85, 85, 85)
                    : Color.lerp(
                        Theme.of(context).brightness == Brightness.light
                            ? const Color.fromARGB(166, 85, 85, 85)
                            : const Color.fromARGB(166, 0, 0, 0),
                        Theme.of(context).colorScheme.primaryContainer,
                        0.35,
                      ),
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
                      tags: tagsAsArknights,
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
                                MediaQuery.textScalerOf(context)
                                        .textScaleFactor -
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

class AudioDialogBox extends ConsumerWidget {
  final String? title;
  final String body;
  final Function()? fun;
  final bool isPlaying;
  final AudioPlayerManager manager;
  final String? audioUrl;
  final String? audioFilename;
  const AudioDialogBox({
    super.key,
    this.title,
    required this.body,
    this.fun,
    this.isPlaying = false,
    required this.manager,
    this.audioUrl,
    this.audioFilename,
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

  void _showDownloadMenu(
    BuildContext context,
    WidgetRef ref,
    LongPressStartDetails details,
  ) {
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        overlay!.size.width - details.globalPosition.dx,
        overlay.size.height - details.globalPosition.dy,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download, size: 20),
              SizedBox(width: 8),
              Text('Download audio'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (!context.mounted) return;
      if (value == 'download') {
        _onDownloadTap(context, ref);
      }
    });
  }

  void _onDownloadTap(BuildContext context, WidgetRef ref) {
    if (audioUrl == null || audioFilename == null) return;

    final confirmEnabled = ref.read(configProvider).audioDownloadConfirmation;
    if (confirmEnabled) {
      _showConfirmDialog(context, ref);
    } else {
      _startDownload(context, ref);
    }
  }

  void _showConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download audio'),
        content: Text('Download "$audioFilename" to your Downloads folder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startDownload(context, ref);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _startDownload(BuildContext context, WidgetRef ref) async {
    if (!ref.read(effectiveIsConnectedProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection')),
      );
      return;
    }

    var sdkApi = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    if (sdkApi < 29) {
      await Permission.storage.request();
    }

    final notificationService = ref.read(notificationProvider);
    final int id = notificationService.getUniqueId();
    final String path = LocalDataManager.download.path;

    notificationService.showDownloadNotification(
      title: 'Downloading',
      body: audioFilename!,
      id: id,
      ongoing: true,
      indeterminate: true,
    );

    final downloaderUtils = DownloaderUtils(
      progressCallback: (current, total) {
        final progress = (current / total) * 100;
        notificationService.showDownloadNotification(
          title: 'Downloading',
          body: audioFilename!,
          id: id,
          ongoing: true,
          indeterminate: false,
          progress: progress.round(),
        );
      },
      file: File('$path/$audioFilename'),
      progress: ProgressImplementation(),
      onDone: () async {
        await notificationService.flutterLocalNotificationsPlugin.cancel(id);
        notificationService.showDownloadNotification(
          title: 'Downloaded',
          body: '$audioFilename finished',
          id: id,
          ongoing: false,
        );
        downloadsBackgroundCores.remove(id.toString());
      },
      deleteOnCancel: true,
      onError: (e) async {
        await notificationService.flutterLocalNotificationsPlugin.cancel(id);
        notificationService.showDownloadNotification(
          title: 'Download failed',
          body: audioFilename!,
          id: id,
          ongoing: false,
        );
        downloadsBackgroundCores.remove(id.toString());
        dev.log('audio download error: $e');
      },
    );

    DownloaderCore core = await Flowder.download(audioUrl!, downloaderUtils);
    downloadsBackgroundCores[id.toString()] = core;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useClassicDialogBox =
        ref.watch(configProvider.select((p) => p.useClassicDialogBox));
    final tagsAsArknights = ref.watch(styleProvider).tagsAsHtml;

    final bool canDownload = audioUrl != null && audioFilename != null;

    Widget content = Stack(
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
            color: useClassicDialogBox
                ? const Color.fromARGB(190, 85, 85, 85)
                : Color.lerp(
                    Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(166, 85, 85, 85)
                        : const Color.fromARGB(166, 0, 0, 0),
                    Theme.of(context).colorScheme.primaryContainer,
                    0.35,
                  ),
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
                        tags: tagsAsArknights,
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
                                final processingState =
                                    playerState?.processingState;
                                final playing = playerState?.playing;
                                if (processingState ==
                                        ProcessingState.loading ||
                                    processingState ==
                                        ProcessingState.buffering) {
                                  return SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                } else if (playing != true) {
                                  return Icon(
                                    Icons.play_arrow,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 32,
                                  );
                                } else if (processingState !=
                                    ProcessingState.completed) {
                                  return Icon(
                                    Icons.pause,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 32,
                                  );
                                } else {
                                  return Icon(
                                    Icons.replay,
                                    color:
                                        Theme.of(context).colorScheme.primary,
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

    if (canDownload) {
      content = GestureDetector(
        onLongPressStart: (details) => _showDownloadMenu(context, ref, details),
        child: content,
      );
    }

    return content;
  }
}
