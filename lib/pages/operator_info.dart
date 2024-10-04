import 'package:autoscale_tabbarview/autoscale_tabbarview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:docsprts/components/custom_tabbar.dart';
import 'package:docsprts/components/utils.dart' show githubEncode;
import 'package:docsprts/global_data.dart';
import 'package:docsprts/pages/operators_page.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:docsprts/providers/ui_provider.dart';
import 'package:docsprts/components/traslucent_ui.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:carousel_slider/carousel_slider.dart';

class OperatorInfo extends StatefulWidget {
  final Operator operator;
  const OperatorInfo(this.operator, {super.key});

  @override
  State<OperatorInfo> createState() => _OperatorInfoState();
}

class _OperatorInfoState extends State<OperatorInfo> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  List<Tab> tabs = <Tab>[
    Tab(text: 'Archive', icon: Icon(Icons.file_present)),
    Tab(text: 'Art', icon: Icon(Icons.filter)),
    Tab(text: 'Voice', icon: Icon(Icons.voice_chat)),
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
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        body: TabBarView(
          controller: _tabController,
          physics: _activeIndex == 1 ? NeverScrollableScrollPhysics() : null,
          children: <Widget>[
            ArchivePage(widget.operator),
            ArtPage(widget.operator),
            VoicePage(widget.operator),
          ],
        ),
        bottomNavigationBar: context.read<UiProvider>().useTranslucentUi ? CustomTabBar(controller: _tabController, tabs: tabs, isTransparent: true) : CustomTabBar(controller: _tabController, tabs: tabs),
      ),
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

    final String ghAvatarLink = 'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/cn/assets/torappu/dynamicassets/arts/charavatars/${operator.id}.png';
    String? logo = operator.teamId ?? operator.groupId ?? operator.nationId;
    if (logo == 'laterano' || logo == 'leithanien') {
      logo = logo!.replaceFirst('l', 'L');
    }
    final String ghLogoLink = logo != 'laios' && logo != 'rainbow' ? 'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/cn/assets/torappu/dynamicassets/arts/camplogo/logo_$logo.png' : 'https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/cn/assets/torappu/dynamicassets/arts/camplogo/linkage/logo_$logo.png';

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          logo != null ? Positioned(right: 1, top: 125, child: Container(decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.25) , spreadRadius: 40, blurRadius: 55)]), child: CachedNetworkImage(colorBlendMode: BlendMode.modulate, color: const Color.fromARGB(150, 255, 255, 255), imageUrl: ghLogoLink, scale: 2.5,))) : Container(),
          Column(
            children: [
              SizedBox(height: const SliverAppBar.medium().toolbarHeight*2),
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
                              child: CachedNetworkImage(colorBlendMode: BlendMode.modulate, color: const Color.fromARGB(99, 255, 255, 255), scale: 0.9, fit: BoxFit.none, placeholder: (context, url) => const Center(child: CircularProgressIndicator()), imageUrl: ghAvatarLink, errorWidget: (context, url, error) => const Center(child: Icon(Icons.error))),
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
                              child: CachedNetworkImage(fit: BoxFit.fitWidth, placeholder: (context, url) => const Center(child: CircularProgressIndicator()), imageUrl: ghAvatarLink, errorWidget: (context, url, error) => const Center(child: Icon(Icons.error))),
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
                  if (index == 2) return ActionChip(label: Text(operator.position), side: BorderSide(color: operator.position == 'RANGED' ? Colors.yellow[600]! : Colors.red), onPressed: (){});
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
  @override
  Widget build(BuildContext context) {
    bool hasParadoxStory = (operator.loreInfo['handbookAvgList'] as List).isNotEmpty;
    List storyTextList = (operator.loreInfo['storyTextAudio'] as List);
    
    return SingleChildScrollView(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: hasParadoxStory ? storyTextList.length+1 : storyTextList.length,
        itemBuilder: (context, index) {
          if (hasParadoxStory && index == storyTextList.length+1-1) {
            return Container(
              height: 60,
              margin: const EdgeInsets.all(8.0),
              child: Center(child: Text('paradox / $index')),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
            child: Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(storyTextList[index]['storyTitle']),
                    Text(((storyTextList[index]['stories'] as List).first as Map)['storyText'])
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}

class SkillInfo extends StatelessWidget {
  const SkillInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: Center(child: Text('here skill things'),)
    );
  }
}

class ArchivePage extends StatelessWidget {
  final Operator operator;
  const ArchivePage(this.operator, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        slivers: [
          SliverStack(
            children: [
              SliverPadding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      HeaderInfo(operator: operator),
                      DefaultTabController(
                       length: 2,
                        child: Column(
                          children: [
                            const TabBar.secondary(
                              indicatorSize: TabBarIndicatorSize.tab,
                              tabs: [
                                Tab(text: 'File'),
                                Tab(text: 'Skills'),
                              ]
                            ),
                            AutoScaleTabBarView(
                              children: [
                                LoreInfo(operator),
                                const SkillInfo()
                              ]
                            )
                          ],
                        )
                      )
                    ]
                  ),
                ),
              ),
              SliverAppBar.medium(
                flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3, child: Container(color: Colors.transparent, child: FlexibleSpaceBar(title: Text(operator.name), titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)))) : FlexibleSpaceBar(title: Text(operator.name), titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)),
                backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                actions: [
                  IconButton(onPressed: (){}, icon: const Icon(Icons.more_horiz))
                ],  
              ),
            ],
          ),
        ],
      );
  }
}

// ------------------------ Art

class ArtPage extends StatefulWidget {
  final Operator operator;
  const ArtPage(this.operator, {super.key});

  @override
  State<ArtPage> createState() => _ArtPageState();
}

class _ArtPageState extends State<ArtPage> {
  int selectedIndex = 0;
  final CarouselSliderController carouselController = CarouselSliderController();
  final PageController _pageController = PageController();

  void changeOpSkin(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    getImageLink(int index) {
      String opSkinId = (widget.operator.skinsList[index]['illustId'] as String).replaceFirst('illust_', '');

      // source ArknightsAssets repo
      return githubEncode('https://raw.githubusercontent.com/ArknightsAssets/ArknightsAssets/cn/assets/torappu/dynamicassets/arts/characters/${widget.operator.id}/$opSkinId.png');
    }


    List<Widget> skinChildren = List.generate(widget.operator.skinsList.length, (int index) {

      // source yuanyan3060 repo
      String avatarLink = githubEncode('https://raw.githubusercontent.com/yuanyan3060/ArknightsGameResource/refs/heads/main/avatar/${widget.operator.skinsList[index]['avatarId']}.png');

      return Container(
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

    void fullscreen() {

    }

    void chibify() {

    }

    void showSkinInfo(){

    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
            IconButton(onPressed: () => showSkinInfo(), icon: const Icon(Icons.info_outline_rounded)),
            IconButton(onPressed: () => chibify(), icon: const Icon(Icons.sync_alt_outlined)),
            IconButton(onPressed: () => fullscreen(), icon: const Icon(Icons.fullscreen)),
          ],
        flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3, child: Container(color: Colors.transparent)) : null,
        backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: ClipRRect(
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: NeverScrollableScrollPhysics(),
              childEnableAlwaysPan: true,
              backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLowest),
              pageController: _pageController,
              itemCount: widget.operator.skinsList.length,
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(getImageLink(index)),
                );
              },
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: carouselContainer(skinChildren, carouselController))
          ],
        ),
      ),
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

}


// --------------------------- Voice

class VoicePage extends StatefulWidget {
  final Operator operator;
  const VoicePage(this.operator, {super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  final player = AudioPlayer();

  @override
  void dispose() {
    player.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> texts = [];
    List<Map<String, dynamic>> filteredCharWord = [];

    for (var value in widget.operator.charWordsList) {
      if (value['wordKey'] == widget.operator.id) {
        filteredCharWord.add(value);
      }
    }

    (widget.operator.voiceLangDict['dict'] as Map<String, dynamic>).forEach((key, value){
      texts.add(Text('${key.toLowerCase()} : ${value["cvName"].toString()}'));
    });

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3, child: Container(color: Colors.transparent, child: FlexibleSpaceBar(title: Text(widget.operator.name), titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)))) : FlexibleSpaceBar(title: Text(widget.operator.name), titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)),
          backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        ),
        SliverPadding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          sliver: SliverList.builder(
            itemCount: filteredCharWord.length+1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: texts),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
                child: Card.outlined(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                    children: [
                      Text(filteredCharWord[index-1]['voiceTitle']),
                      Text(filteredCharWord[index-1]['voiceText'])
                    ],
                  ),
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}
