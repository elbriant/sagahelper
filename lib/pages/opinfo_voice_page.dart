import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/components/dialog_box.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/utils/extensions.dart';

class VoicePage extends StatefulWidget {
  final Operator operator;
  const VoicePage(this.operator, {super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> with WidgetsBindingObserver {
  final AudioPlayerManager manager = AudioPlayerManager();
  int selectedLang = 0;
  List voicelines = [];
  String selectedVoicelines = '';
  List<String> langs = [];
  List<Map<String, dynamic>> filteredCharWord = [];
  int playingIndex = -1;
  PlayerState? playerState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    manager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      manager.stop();
    }
  }

  void _init() {
    for (var key in (widget.operator.voiceLangDict['dict'] as Map<String, dynamic>).keys) {
      langs.add(key.toLowerCase());
      if (key == 'JP') selectedLang = langs.indexOf('jp');
    }

    voicelines.add(widget.operator.id);
    for (var skin in widget.operator.skinsList) {
      if (skin["voiceId"] != null) {
        if (voicelines.contains(skin["voiceId"])) continue;
        voicelines.add(skin["voiceId"]);
      }
    }
    selectedVoicelines = voicelines.first;

    manager.player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        if (e is PlatformException) {
          ShowSnackBar.showSnackBar(
            'Error code: ${e.code}, Error message: ${e.message}, AudioSource index: ${e.details?["index"]}',
            type: SnackBarType.failure,
          );
        } else {
          ShowSnackBar.showSnackBar(
            'An error occurred: $e',
            type: SnackBarType.failure,
          );
        }
      },
    );

    manager.player.playerStateStream.listen((state) {
      playerState = state;
    });
  }

  void changeVoiceline(String? voiceline) {
    setState(() {
      selectedVoicelines = voiceline ?? voicelines.first;
    });
    if (manager.player.playing) {
      managerPlay(filteredCharWord[playingIndex - 2]["voiceId"], playingIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    filteredCharWord = [];
    for (var value in widget.operator.charWordsList) {
      if (value['wordKey'] == selectedVoicelines) {
        filteredCharWord.add(value);
      }
    }

    List<Widget> langsButtons = List.generate(langs.length, (index) {
      String label = switch (langs[index]) { 'cn_mandarin' => 'CN', 'cn_topolect' => 'CN', 'linkage' => 'CUSTOM', String() => langs[index].toUpperCase() };

      String? sublabel = switch (langs[index]) { 'cn_mandarin' => 'Mandarin', 'cn_topolect' => 'Topolect', String() => null };

      String va = ((widget.operator.voiceLangDict['dict'] as Map<String, dynamic>)[langs[index].toUpperCase()]["cvName"] as List).join(', ');

      return StyledLangButton(
        label: label,
        sublabel: sublabel,
        vaName: va,
        selected: index == selectedLang,
        onTap: () {
          selectLang(index);
        },
      );
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true
            ? TranslucentWidget(
                sigma: 3,
                child: Container(
                  color: Colors.transparent,
                  child: FlexibleSpaceBar(
                    title: Text(widget.operator.name),
                    titlePadding: const EdgeInsets.only(
                      left: 72.0,
                      bottom: 16.0,
                      right: 32.0,
                    ),
                  ),
                ),
              )
            : FlexibleSpaceBar(
                title: Text(widget.operator.name),
                titlePadding: const EdgeInsets.only(
                  left: 72.0,
                  bottom: 16.0,
                  right: 32.0,
                ),
              ),
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: List.generate(filteredCharWord.length + 2, (index) {
              if (index == 0) {
                return Card.filled(
                  margin: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 24.0,
                  ),
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(5.0),
                    margin: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 6.0,
                    ),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceEvenly,
                      runSpacing: 10.0,
                      spacing: 6.0,
                      children: langsButtons,
                    ),
                  ),
                );
              } else if (index == 1) {
                // voicelines
                if (voicelines.length > 1) {
                  return Card.filled(
                    margin: const EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 24.0,
                    ),
                    child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(5.0),
                      margin: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 6.0,
                      ),
                      child: DropdownMenu(
                        initialSelection: selectedVoicelines,
                        label: const Text('Voicelines'),
                        leadingIcon: Icon(
                          Icons.record_voice_over_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        width: double.maxFinite,
                        onSelected: changeVoiceline,
                        dropdownMenuEntries: voicelines.map<DropdownMenuEntry<String>>((name) {
                          return DropdownMenuEntry<String>(
                            value: name,
                            label: name,
                          );
                        }).toList(),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 12.0),
                child: AudioDialogBox(
                  title: filteredCharWord[index - 2]['voiceTitle'],
                  body: (filteredCharWord[index - 2]['voiceText'] as String).nicknameParser(),
                  isPlaying: playingIndex == index,
                  manager: manager,
                  fun: () {
                    play(filteredCharWord[index - 2]["voiceId"], index);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void selectLang(int index) {
    setState(() {
      selectedLang = index;
    });
    if (manager.player.playing) {
      managerPlay(filteredCharWord[playingIndex - 2]["voiceId"], playingIndex);
    }
  }

  void managerPlay(String voiceId, int index) {
    if (playingIndex != index) {
      setState(() {
        playingIndex = index;
      });
    }
    // get link using Aceship's repo
    String voicelang = switch (langs[selectedLang]) { 'jp' => 'voice', 'en' => 'voice_en', 'kr' => 'voice_kr', 'cn_mandarin' => 'voice_cn', 'linkage' => 'voice', String() => 'voice_custom' };

    String opId = selectedVoicelines;

    if (voicelang == 'voice_custom') {
      opId += switch (langs[selectedLang]) { 'cn_topolect' => '_cn_topolect', 'ita' => '_ita', String() => '' };
    }

    String link = '$kVoiceRepo/$voicelang/$opId/$voiceId.mp3'.githubEncode();

    manager.init(link);
  }

  // not proud of this code
  void play(String voiceId, int index) {
    final processingState = playerState?.processingState;
    final playing = playerState?.playing;

    if (playing == true) {
      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
        // is loading something
        if (index != playingIndex) {
          manager.stop();
          managerPlay(voiceId, index);
        }
      } else if (processingState == ProcessingState.completed) {
        // replay
        managerPlay(voiceId, index);
      } else if (processingState != ProcessingState.completed) {
        // pause
        if (index != playingIndex) {
          managerPlay(voiceId, index);
        } else {
          manager.pause();
        }
      }
    } else {
      if (processingState != ProcessingState.completed) {
        // paused
        if (index != playingIndex) {
          managerPlay(voiceId, index);
        } else {
          manager.play();
        }
      }
    }
  }
}
