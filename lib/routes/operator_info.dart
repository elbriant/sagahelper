import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flowder/flowder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sagahelper/components/custom_tabbar.dart';
import 'package:sagahelper/components/dialog_box.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/components/text_styles.dart';
import 'package:sagahelper/components/utils.dart' show ListExtension, StringExtension;
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:styled_text/styled_text.dart';
import 'package:rxdart/rxdart.dart' show Rx;
import 'package:device_info_plus/device_info_plus.dart';

class OperatorInfo extends StatefulWidget {
  final Operator operator;
  const OperatorInfo(this.operator, {super.key});

  @override
  State<OperatorInfo> createState() => _OperatorInfoState();
}

class _OperatorInfoState extends State<OperatorInfo> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Tab> tabs = <Tab>[
    const Tab(text: 'Archive', icon: Icon(Icons.file_present)),
    const Tab(text: 'Art', icon: Icon(Icons.filter)),
    const Tab(text: 'Voice', icon: Icon(Icons.voice_chat)),
  ];
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    _tabController.addListener(() {
      setState(() {
        _activeIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: TabBarView(
        controller: _tabController,
        physics: _activeIndex == 1 ? const NeverScrollableScrollPhysics() : null,
        children: <Widget>[
          ArchivePage(widget.operator),
          ArtPage(widget.operator),
          VoicePage(widget.operator),
        ],
      ),
      bottomNavigationBar: context.read<UiProvider>().useTranslucentUi ? CustomTabBar(controller: _tabController, tabs: tabs, isTransparent: true) : CustomTabBar(controller: _tabController, tabs: tabs),
    );
  }
}




// -------------------- Archive

class HeaderInfo extends StatelessWidget {
  const HeaderInfo({super.key, required this.operator});
  final Operator operator;

  @override
  Widget build(BuildContext context) {
    final professionStr = 'assets/classes/class_${operator.profession.toLowerCase()}.png';
    final subprofessionStr = 'assets/subclasses/sub_${operator.subProfessionId.toLowerCase()}_icon.png';

    final String ghAvatarLink = '$kAvatarRepo/${operator.id}.png';
    String? logo = operator.teamId ?? operator.groupId ?? operator.nationId;
    if (logo == 'laterano' || logo == 'leithanien') {
      logo = logo!.replaceFirst('l', 'L');
    }
    final String ghLogoLink = logo == 'laios' || logo == 'rainbow' ? '$kLogoRepo/linkage/logo_$logo.png' : '$kLogoRepo/logo_$logo.png';

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          logo != null ? Positioned(
            right: 1,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.25), spreadRadius: 40, blurRadius: 55)
                ]
              ),
              child: CachedNetworkImage(
                colorBlendMode: BlendMode.modulate,
                color: const Color.fromARGB(150, 255, 255, 255),
                imageUrl: ghLogoLink,
                scale: 2.5,
                placeholder: (_, __) => Image.asset('assets/placeholders/logo.png', colorBlendMode: BlendMode.modulate, color: Colors.transparent),
                errorWidget: (context, url, error) => Stack(
                  children: [
                    Image.asset('assets/placeholders/logo.png', colorBlendMode: BlendMode.modulate, color: Colors.transparent),
                    Positioned.fill(child: Center(child: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.surface))),
                  ],
                ),
              )
            )
          ) : Container(),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform(
                            transform: Matrix4.translationValues(-20, 10, -1)..rotateZ(-0.088),
                            child: Container(
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                              boxShadow: const <BoxShadow>[
                                BoxShadow (
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                  offset: Offset(0, 8.0),
                                  blurRadius: 10.0,
                                ),
                              ],
                              border: Border.all(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                width: 4.0,
                                style: BorderStyle.solid
                                ),
                              ),
                              child: CachedNetworkImage(
                                colorBlendMode: BlendMode.modulate,
                                color: const Color.fromARGB(99, 255, 255, 255),
                                scale: 0.9,
                                fit: BoxFit.fitWidth,
                                placeholder: (context, url) => Image.asset('assets/placeholders/avatar.png', colorBlendMode: BlendMode.modulate, color: Colors.transparent),
                                imageUrl: ghAvatarLink,
                                errorWidget: (context, url, error) => Image.asset('assets/placeholders/avatar.png', colorBlendMode: BlendMode.modulate, color: Colors.transparent),
                              ),
                            ),
                          ),
                          Transform(
                            transform: Matrix4.rotationZ(0.034),
                            child: Container(
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                boxShadow: const <BoxShadow>[
                                  BoxShadow (
                                    color: Color.fromRGBO(0, 0, 0, 0.5),
                                    offset: Offset(0, 8.0),
                                    blurRadius: 10.0,
                                  ),
                                ],
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  width: 4.0,
                                  style: BorderStyle.solid
                                  ),
                                color: const Color.fromARGB(255, 241, 241, 241),
                              ),
                              child: CachedNetworkImage(
                                fit: BoxFit.fitWidth,
                                placeholder: (context, url) => Stack(
                                  children: [
                                    Image.asset('assets/placeholders/avatar.png', colorBlendMode: BlendMode.modulate, color: Colors.transparent),
                                    const Positioned.fill(child: Center(child: CircularProgressIndicator())),
                                  ],
                                ),
                                imageUrl: ghAvatarLink,
                                errorWidget: (context, url, error) => Stack(
                                  children: [
                                    Image.asset('assets/placeholders/avatar.png', colorBlendMode: BlendMode.modulate, color: Colors.transparent),
                                    Positioned.fill(child: Center(child: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.primary))),
                                  ],
                                )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox())
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '[${operator.displayNumber} / ${operator.id}]\n', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5) , fontStyle: FontStyle.italic)),
                      TextSpan(text: operator.itemUsage),
                      TextSpan(text: '\n${operator.itemDesc}', style: const TextStyle(fontStyle: FontStyle.italic))
                    ]
                  )
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: List.generate(operator.tagList.length+3, (index) {
                  if (index == 0) return ActionChip(label: Text(operator.professionString), avatar: Image.asset(professionStr), backgroundColor: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.primary.withOpacity(0.7) : null, labelStyle: Theme.of(context).brightness == Brightness.light ? const TextStyle(color: Colors.white) : null, onPressed: (){});
                  if (index == 1) return ActionChip(label: Text(operator.subProfessionString), avatar: Image.asset(subprofessionStr), backgroundColor: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.primary.withOpacity(0.7) : null, labelStyle: Theme.of(context).brightness == Brightness.light ? const TextStyle(color: Colors.white) : null, onPressed: (){});
                  if (index == 2) return ActionChip(label: Text(operator.position.toLowerCase().capitalize()), side: BorderSide(color: operator.position == 'RANGED' ? Colors.yellow[600]! : Colors.red), onPressed: (){});
                  return ActionChip(label: Text(operator.tagList[index-3]), side: BorderSide(color: Theme.of(context).colorScheme.tertiary), onPressed: (){});
                }),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class LoreInfo extends StatelessWidget {
  const LoreInfo(this.operator, {super.key});
  final Operator operator;

  void playOperatorRecord() {
    ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(const SnackBar(content: Text('not implemented yet')));
  }

  @override
  Widget build(BuildContext context) {
    bool hasOperatorRecords = (operator.loreInfo['handbookAvgList'] as List).isNotEmpty;
    List storyTextList = (operator.loreInfo['storyTextAudio'] as List);
    List operatorRecords = (operator.loreInfo['handbookAvgList'] as List);
    
    return Column (
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        hasOperatorRecords ? storyTextList.length+operatorRecords.length : storyTextList.length ,
        (index) {
          if (hasOperatorRecords && index >= storyTextList.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
              child: InkWellDialogBox(
                title: 'Operator Record: ${operatorRecords[index-storyTextList.length]['storySetName']}',
                body: ((operatorRecords[index-storyTextList.length]['avgList'] as List).first as Map)['storyIntro'],
                inkwellFun: playOperatorRecord,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
            child: DialogBox(
              title: storyTextList[index]['storyTitle'],
              body: ((storyTextList[index]['stories'] as List).first as Map)['storyText'],
            ),
          );
        }
      ),
    );
  }
}

class SkillInfo extends StatefulWidget {
  final Operator operator;
  const SkillInfo(this.operator, {super.key});

  @override
  State<SkillInfo> createState() => _SkillInfoState();
}

class _SkillInfoState extends State<SkillInfo> {
  double showLevel = 83.0;
  double maxLevel = 90;
  int elite = 0;
  int pot = 0;
  int sliderTrust = 100;
  bool trustMaxFlag = true;

  void _init() {
    //get max elite
    elite = widget.operator.phases.length-1;
    maxLevel = (widget.operator.phases[elite]["maxLevel"] as int).toDouble();
    showLevel = maxLevel;
  }

  String? getTraitText() {
    String? trait;

    if (widget.operator.trait !=  null) {
      for (int phase = elite; phase >= 0 ; phase--) {
        for (Map candidate in (widget.operator.trait!["candidates"] as List)) {
          if (candidate["unlockCondition"]["phase"] == 'PHASE_${phase.toString()}') {
            trait = candidate["overrideDescripton"];
            break;
          }
        }
        if (trait != null) {
          break;
        }
      }
    }
    return trait ?? widget.operator.description;
  }

  List<dynamic>? getTraitsVars() {
    List<dynamic>? vars;

    if (widget.operator.trait !=  null) {
      for (int phase = elite; phase >= 0 ; phase--) {
        for (Map candidate in (widget.operator.trait!["candidates"] as List)) {
          if (candidate["unlockCondition"]["phase"] == 'PHASE_${phase.toString()}') {
            vars = candidate["blackboard"];
            break;
          }
        }
        if (vars != null) {
          break;
        }
      }
    }
    return vars;
  }

  String getStat(String stat) {
    List<dynamic> datakeyframe = widget.operator.phases[elite]['attributesKeyFrames'];

    if (stat == 'baseAttackTime' || stat == 'respawnTime') {
      return ui.lerpDouble(datakeyframe[0]['data'][stat], datakeyframe[1]['data'][stat], (showLevel-1.0)/(maxLevel-1))!.toString();
    } else {
      return ui.lerpDouble(datakeyframe[0]['data'][stat], datakeyframe[1]['data'][stat], (showLevel-1.0)/(maxLevel-1))!.round().toString();
    }
  }

  void selectElite(int i) {
    if (elite == i) return;

    setState(() {
      elite = i;
      maxLevel = (widget.operator.phases[elite]["maxLevel"] as int).toDouble();
      showLevel = showLevel.clamp(1, maxLevel);
    });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> statTiles = [
      statTile('HP', getStat('maxHp')),
      statTile('ATK', getStat('atk')),
      statTile('Redeploy', '${getStat('respawnTime')} sec'),
      statTile('Block', getStat('blockCnt')),
      statTile('DEF', getStat('def')),
      statTile('RES', '${getStat('magicResistance')}%'),
      statTile('DP Cost', getStat('cost')),
      statTile('ASPD', '${getStat('baseAttackTime')} sec')
    ];
    // maybe hold tap on elite, skill and mod to show cost material
    // do a tip show to say this ||
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          getTraitText() != null ? Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0)
            ),
            child: Column(
              children: [
                const Text('Trait'),
                StyledText(
                  text: getTraitText()!.varParser(getTraitsVars()).akRichTextParser(),
                  tags: tagsAsArknights,

                )
              ],
            )
          ) : null,
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0)
            ),
            child: Column(
              children: [
                Wrap(
                  spacing: 20.0,
                  runSpacing: 20.0,
                  children: statTiles
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(child: potTile()),
                    Expanded(child: rangeTile()),
                  ],
                ),
                Row(
                  children: [
                    LilButton(
                      selected: elite == 0,
                      fun: (){selectElite(0);},
                      icon: const ImageIcon(AssetImage('assets/elite/elite_0.png')),
                    ),
                    widget.operator.phases.length > 1 ? LilButton(
                      selected: elite == 1,
                      fun: (){selectElite(1);},
                      icon: const ImageIcon(AssetImage('assets/elite/elite_1.png')),
                    ) : null,
                    widget.operator.phases.length > 2 ? LilButton(
                      selected: elite == 2,
                      fun: (){selectElite(2);},
                      icon: const ImageIcon(AssetImage('assets/elite/elite_2.png')),
                    ) : null,
                    Text('Trust:\nMAX'),
                    Expanded(
                      child: Column(
                        children: [
                          Slider(
                            value: 50,
                            max: 100,
                            min: 0,
                            onChanged: (value){},
                          ),
                          Text('atributtes')
                        ].nullParser(),
                      )
                    ),
                  ].nullParser(),
                ),
                Row(
                  children: [
                    Text('Lv: '),
                    Expanded(
                      child: Slider(
                        value: showLevel,
                        max: maxLevel,
                        min: 1.0,
                        divisions: maxLevel.toInt(),
                        onChanged: (value){
                          setState(() {
                            showLevel = value.roundToDouble();
                          });
                        },
                      ),
                    ),
                    Text(showLevel.toInt().toString().padLeft(2, '  '))
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0)
            ),
            child: SizedBox(
              height: 240,
              child: Placeholder(
                child: Text('talents'),
              )
            )
          ),
          const SizedBox(height: 20),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0)
            ),
            child: 
            
            // skills needs to have: maybe a custom range show, maybe a custom summon show, maybe a lv upgrade diff shower (really easy to do), maybe a item cost to lvel
            
            SizedBox(
              height: 240,
              child: Placeholder(
                child: Text('Skilss'),
              )
            )
          ),
          const SizedBox(height: 20),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0)
            ),
            child: 
            // mods needs to have: maybe a lv upgrade diff shower stats (really easy to do), story show
            
            SizedBox(
              height: 240,
              child: Placeholder(
                child: Text('Modules'),
              )
            )
          ),
          const SizedBox(height: 20),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.0)
            ),
            child: SizedBox(
              height: 240,
              child: Placeholder(
                child: Text('RIIC Base Skills'),
              )
            )
          ),
        ].nullParser(),
      ),
    );
  }

  Widget statTile(String stat, String value) {
    return StyledText(
      text: '<icon-${stat.replaceAll(r' ', '')}/><color stat="${stat.replaceAll(' ', '')}">$stat</color>\n$value',
      tags: tagsAsStats,
    );
  }

  Widget potTile() {
     return const Center(
      child: Text('here pots')
    );
  }

  Widget rangeTile() {
     return const Center(
      child: Text('here range')
    );
  }
  
}

class ArchivePage extends StatefulWidget {
  final Operator operator;
  const ArchivePage(this.operator, {super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> with SingleTickerProviderStateMixin {
  late TabController _secondaryTabController;
  late final List<Widget> _secChildren;
  int _activeIndex = 0;
  final List<Tab> _secTabs = <Tab>[const Tab(text: 'Combat'), const Tab(text: 'File')];

  @override
  void initState() {
    super.initState();
    _secondaryTabController = TabController(vsync: this, length: _secTabs.length);
    _secondaryTabController.addListener(() {
      setState(() {
        _activeIndex = _secondaryTabController.index;
      });
    });

    _secChildren = [
      SkillInfo(widget.operator),
      LoreInfo(widget.operator)
    ];
  }

  @override
  void dispose() {
    _secondaryTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.medium(
          flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(
            child: FlexibleSpaceBar(
              title: Text(widget.operator.name),
              titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)
            ),
          ) : FlexibleSpaceBar(
            title: Text(widget.operator.name),
            titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)
          ),
          backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(onPressed: (){}, icon: const Icon(Icons.more_horiz))
          ],
        ),
        SliverList.list(
          children: [
            HeaderInfo(operator: widget.operator),
            TabBar.secondary(
              controller: _secondaryTabController,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: _secTabs
            ),
            const SizedBox(height: 20)
          ]
        ),
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return AnimatedSwitcher.defaultTransitionBuilder(child, animation);
            },
            child: _secChildren[_activeIndex]
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom)
        )
      ]
    );
  }
}

// ------------------------ Art

enum ChibiMode {back, front, build}

class ArtPage extends StatefulWidget {
  final Operator operator;
  const ArtPage(this.operator, {super.key});

  @override
  State<ArtPage> createState() => _ArtPageState();
}

class _ArtPageState extends State<ArtPage> {
  int selectedIndex = 0;
  bool chibimode = false;
  bool hasDynamicArt = false;
  bool dynamicArt = false;
  final CarouselSliderController carouselController = CarouselSliderController();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void changeOpSkin(int index) {
    selectedIndex = index;
    if (widget.operator.skinsList[selectedIndex]["dynIllustId"] != null && hasDynamicArt == false) {
      setState(() {
        hasDynamicArt = true;
      });
    } else if (widget.operator.skinsList[selectedIndex]["dynIllustId"] == null && hasDynamicArt == true) {
      setState(() {
        hasDynamicArt = false;
      });
    }
    if (!chibimode) _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  String getImageLink(int index) {
    String opSkinId = (widget.operator.skinsList[index]['illustId'] as String).replaceFirst('illust_', '');
    return '$kArtRepo/${widget.operator.id}/$opSkinId.png'.githubEncode();
  }

  void showDynamicSkin() {
    ShowSnackBar.showSnackBar('dynamic art not supported yet');
  }

  void fullscreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => FullscreenArtsPage(NetworkImage(getImageLink(selectedIndex)), selectedIndex: selectedIndex, chibi: chibimode,)));
  }

  void chibify() {
    setState(() {
      chibimode = !chibimode;
    });
  }

  void downloadArt() async {
    Navigator.pop(context);

    // this download may or may not work as i currently can't test
    // downloading for API >= 29 doesn't require permissons (Android provides permissons for shared media)
    // downloading for API < 29 does requires permissons and hopefully the line below provides it
    var sdkApi = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    if (sdkApi < 29) {
      Permission.storage.request();
    }

    int id = getUniqueId();
    String path = await LocalDataManager().downloadPath;

    showDownloadNotification(title: 'Downloading', body: 'downloading image', id: id, ongoing: true, indeterminate: true);
    
    String skin = (widget.operator.skinsList[selectedIndex]['illustId'] as String).replaceFirst('illust_', '');
    String link = '$kArtRepo/${widget.operator.id}/$skin.png'.githubEncode();
    
    final downloaderUtils = DownloaderUtils(
      progressCallback: (current, total) {
        final progress = (current / total) * 100;
        showDownloadNotification(title: 'Downloading', body: skin, id: id, ongoing: true, indeterminate: false, progress: progress.round());
      },
      file: File('$path/$skin.png'),
      progress: ProgressImplementation(),
      onDone: () async {
        await flutterLocalNotificationsPlugin.cancel(id);
        showDownloadNotification(title: 'Downloaded', body: '$skin finished', id: id, ongoing: false);
        downloadsBackgroundCores.remove(id.toString());
      },
      deleteOnCancel: true,
      onError: (e) => dev.log('error: $e')
    );
              
    DownloaderCore core = await Flowder.download(link, downloaderUtils);
    downloadsBackgroundCores[id.toString()] = core;
  }
  
  void showSkinInfo() async {
    await showModalBottomSheet<void>(
      constraints: BoxConstraints.loose(Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.75)),
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        Map skinInfo = widget.operator.skinsList[selectedIndex];
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  skinInfo["displaySkin"]["skinName"] != null ? Text(skinInfo["displaySkin"]["skinName"], style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary), textScaler: const TextScaler.linear(1.5)) : Text(skinInfo["displaySkin"]["skinGroupName"], style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface), textScaler: const TextScaler.linear(1.5)),
                  skinInfo["skinId"] != null ? Text(skinInfo["skinId"], style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontStyle: FontStyle.italic)) : null,
                  const SizedBox(height: 20),
                  skinInfo["displaySkin"]["modelName"] != null ? Text('Model: ${skinInfo["displaySkin"]["modelName"]}') : null,
                  skinInfo["displaySkin"]["drawerList"] != null ? Text('Drawer: ${(skinInfo["displaySkin"]["drawerList"] as List).join(', ')}') : null,
                  skinInfo["displaySkin"]["skinGroupName"] != null ? Text('Series: ${skinInfo["displaySkin"]["skinGroupName"]}') : null,
                  const SizedBox(height: 20),
                  skinInfo["displaySkin"]["content"] != null ? Container(margin: const EdgeInsets.only(bottom: 10.0), child: StyledText(text: skinInfo["displaySkin"]["content"], tags: tagsAsArknights, style: TextStyle(color: skinInfo["displaySkin"]["skinName"] != null ? Theme.of(context).colorScheme.secondary : null))) : null,
                  skinInfo["displaySkin"]["usage"] != null ? Container(margin: const EdgeInsets.only(bottom: 10.0), child: StyledText(text: skinInfo["displaySkin"]["usage"], tags: tagsAsArknights)) : null,
                  skinInfo["displaySkin"]["description"] != null ? Container(margin: const EdgeInsets.only(bottom: 10.0), child: StyledText(text: skinInfo["displaySkin"]["description"], tags: tagsAsArknights, style: const TextStyle(fontStyle: FontStyle.italic),)) : null,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      IconButtonStyled(icon: Icons.file_download_outlined, label: 'Download image', onTap: downloadArt, selected: true),
                    ]
                  ),
                ].nullParser(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> skinChildren = List.generate(widget.operator.skinsList.length, (int index) {
      String avatarLink = '$kAvatarRepo/${widget.operator.skinsList[index]['avatarId']}.png'.githubEncode();

      return Container(
        width: 80, //same as height to have a 1:1 box
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Theme.of(context).colorScheme.secondary, strokeAlign: BorderSide.strokeAlignInside, width: 1.5)
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              CachedNetworkImage(imageUrl: avatarLink, errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)), placeholder: (context, url) => const Center(child: CircularProgressIndicator())),
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => carouselController.animateToPage(index, curve: Curves.easeOutCubic),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
            Visibility(visible: !chibimode, child: IconButton(onPressed: () => showSkinInfo(), icon: const Icon(Icons.info_outline_rounded))),
            IconButton(onPressed: () => chibify(), icon: const Icon(Icons.sync_alt_outlined)),
            Hero(tag: 'button', child: IconButton(onPressed: () => fullscreen(), icon: const Icon(Icons.fullscreen))),
          ],
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3, child: Container(color: Colors.transparent)) : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: ClipRect(
        child: Stack(
          children: [
            Stack(
              children: [
                Visibility(visible: !chibimode, maintainState: true, child: photoview(context, getImageLink)),
                Visibility(visible: chibimode, maintainState: true, child: chibiview())
              ],
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: carouselContainer(skinChildren, carouselController)),
            hasDynamicArt && chibimode == false? Positioned(right: 0, bottom: 0, child: dynamicSkinButton()) : null
          ].nullParser(),
        ),
      )
    );
  }

  Widget chibiview() {
    return const Center(
      child: Text('Chibi not supported yet'),
    );
  }

  PhotoViewGallery photoview(BuildContext context, String Function(int index) getImageLink) {
    return PhotoViewGallery.builder(
          scrollPhysics: const NeverScrollableScrollPhysics(),
          childEnableAlwaysPan: true,
          backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLowest),
          pageController: _pageController,
          itemCount: widget.operator.skinsList.length,
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              filterQuality: FilterQuality.high,
              imageProvider: NetworkImage(getImageLink(index)),
              heroAttributes: PhotoViewHeroAttributes(tag: '$selectedIndex hero')
            );
          },
        );
  }

  Widget carouselContainer (List<Widget> children, CarouselSliderController controller) {
    final double height = 80;

    if (NavigationService.navigatorKey.currentContext!.read<UiProvider>().useTranslucentUi) {
      return TranslucentWidget(
        child: Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          height: height,
          color: Theme.of(context).colorScheme.surfaceDim.withOpacity(0.5),
          child: CarouselSlider(
            carouselController: controller,
            items: children,
            options: CarouselOptions(
              onPageChanged: (int index, _) => changeOpSkin(index),
              enableInfiniteScroll: false,
              viewportFraction: 0.3,
            )
          ),
        )
      );
    } else {
      return Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        height: height,
        color: Theme.of(context).colorScheme.surfaceDim,
        child: CarouselSlider(
          carouselController: controller,
          items: children,
          options: CarouselOptions(
            onPageChanged: (int index, _) => changeOpSkin(index),
            enableInfiniteScroll: false,
            viewportFraction: 0.3
          )
        ),
      );
    }
  }
  
  Widget dynamicSkinButton() {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom+80+20, right: 20),
      child: FloatingActionButton.small(onPressed: (){showDynamicSkin();}, child: const Icon(Icons.play_arrow))
    );
  }

}

class FullscreenArtsPage extends StatefulWidget {
  const FullscreenArtsPage(this.image, {super.key, required this.selectedIndex, required this.chibi});

  final NetworkImage image;
  final int selectedIndex;
  final bool chibi;

  @override
  State<FullscreenArtsPage> createState() => _FullscreenArtsPageState();
}

class _FullscreenArtsPageState extends State<FullscreenArtsPage> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void fullscreen() {
      Navigator.pop(context);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          Hero(tag: 'button', child: IconButton(onPressed: () => fullscreen(), icon: const Icon(Icons.fullscreen_exit)))
        ],
        backgroundColor: Colors.transparent,
        leading: const SizedBox()
      ),
      body: widget.chibi
        ? const Center(
          child: Text('Chibi not supported yet'),
        )
        : PhotoView(
        enablePanAlways: true,
        filterQuality: FilterQuality.high,
        imageProvider: widget.image,
        backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLowest),
        heroAttributes: PhotoViewHeroAttributes(tag: '${widget.selectedIndex} hero'),
      )
    );
  }
}


// --------------------------- Voice

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
            ));
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

    manager.player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
      if (e is PlatformException) {
        ShowSnackBar.showSnackBar('Error code: ${e.code}, Error message: ${e.message}, AudioSource index: ${e.details?["index"]}', type: SnackBarType.failure);
      } else {
        ShowSnackBar.showSnackBar('An error occurred: $e', type: SnackBarType.failure);
      }
    });

    manager.player.playerStateStream.listen((state) {
      playerState = state;
    });

  }

  void changeVoiceline(String? voiceline) {
    setState(() {
      selectedVoicelines = voiceline ?? voicelines.first;
    });
    if (manager.player.playing) {
      managerPlay(filteredCharWord[playingIndex-2]["voiceId"], playingIndex);
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

    List<Widget> langsButtons = List.generate(langs.length, (index){

      String label = switch (langs[index]) {
        'cn_mandarin' => 'CN',
        'cn_topolect' => 'CN',
        'linkage' => 'CUSTOM',
        String() => langs[index].toUpperCase()
      };

      String? sublabel = switch (langs[index]) {
        'cn_mandarin' => 'Mandarin',
        'cn_topolect' => 'Topolect',
        String() => null
      };

      String va = ((widget.operator.voiceLangDict['dict'] as Map<String, dynamic>)[langs[index].toUpperCase()]["cvName"] as List).join(', ');

      return StyledLangButton(label: label, sublabel: sublabel, vaName: va, selected: index == selectedLang, onTap: (){selectLang(index);});
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3, child: Container(color: Colors.transparent, child: FlexibleSpaceBar(title: Text(widget.operator.name), titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)))) : FlexibleSpaceBar(title: Text(widget.operator.name), titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)),
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: List.generate(
              filteredCharWord.length+2,
              (index) {
                if (index == 0) {
                  return Card.filled(
                    margin: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                    child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(5.0),
                        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
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
                      margin: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                      child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(5.0),
                        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                        child: DropdownMenu(
                          initialSelection: selectedVoicelines,
                          label: const Text('Voicelines'),
                          leadingIcon: Icon(Icons.record_voice_over_rounded, color: Theme.of(context).colorScheme.primary),
                          width: double.maxFinite,
                          onSelected: changeVoiceline,
                          dropdownMenuEntries: voicelines.map<DropdownMenuEntry<String>>(
                            (name) {
                              return DropdownMenuEntry<String>(value: name, label: name);
                            }
                          ).toList()
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
                    title: filteredCharWord[index-2]['voiceTitle'],
                    body: (filteredCharWord[index-2]['voiceText'] as String).nicknameParser(),
                    isPlaying: playingIndex == index,
                    manager: manager,
                    fun: (){play(filteredCharWord[index-2]["voiceId"], index);},
                  ),
                );
              }
            ),
          ),
        ),
      )
    );
  }

  void selectLang(int index){
    setState(() {
      selectedLang = index;
    });
    if (manager.player.playing) {
      managerPlay(filteredCharWord[playingIndex-2]["voiceId"], playingIndex);
    }
  }

  void managerPlay(String voiceId, int index) {
    if (playingIndex != index) {
      setState(() {
        playingIndex = index;
      });
    }
    // get link using Aceship's repo
    String voicelang = switch (langs[selectedLang]) {
      'jp' => 'voice',
      'en' => 'voice_en',
      'kr' => 'voice_kr',
      'cn_mandarin' => 'voice_cn',
      'linkage' => 'voice',
      String() => 'voice_custom'
    };

    String opId = selectedVoicelines;

    if(voicelang == 'voice_custom') {
      opId += switch (langs[selectedLang]) {
        'cn_topolect' => '_cn_topolect',
        'ita' => '_ita',
        String() => ''
      };
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
