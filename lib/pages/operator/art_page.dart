import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/components/styled_buttons.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/core/navigation_service.dart';
import 'package:sagahelper/core/snack_bar_service.dart';
import 'package:sagahelper/models/config/local_data_manager.dart';
import 'dart:developer' as dev;
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/core/notification_service.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/providers/style_provider.dart';
import 'package:sagahelper/utils/extensions.dart';
import 'package:styled_text/styled_text.dart';

enum ChibiMode { back, front, build }

class ArtPage extends ConsumerStatefulWidget {
  final Operator operator;
  const ArtPage(this.operator, {super.key});

  @override
  ConsumerState<ArtPage> createState() => _ArtPageState();
}

class _ArtPageState extends ConsumerState<ArtPage> {
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
    } else if (widget.operator.skinsList[selectedIndex]["dynIllustId"] == null &&
        hasDynamicArt == true) {
      setState(() {
        hasDynamicArt = false;
      });
    }
    if (!chibimode) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  String getImageLink(int index) {
    String opSkinId =
        (widget.operator.skinsList[index]['illustId'] as String).replaceFirst('illust_', '');
    return '$kArtRepo/$opSkinId.png'.githubEncode();
  }

  void showDynamicSkin() {
    SnackBarService.showSnackBar('dynamic art not supported yet');
  }

  void fullscreen() {
    String opSkinId = (widget.operator.skinsList[selectedIndex]['illustId'] as String)
        .replaceFirst('illust_', '');
    Navigator.push(
      NavigationService.rootNavigatorKey.currentContext ?? context,
      MaterialPageRoute(
        builder: (context) => FullscreenArtsPage(
          NetworkToFileImage(
            url: getImageLink(selectedIndex),
            file: LocalDataManager.localCacheFile(
              '${widget.operator.id}_$opSkinId.png',
              CacheType.operatorArt,
            ),
          ),
          selectedIndex: selectedIndex,
          chibi: chibimode,
        ),
      ),
    );
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

    final notificationService = ref.read(notificationProvider);
    final int id = notificationService.getUniqueId();
    final String path = LocalDataManager.download.path;

    notificationService.showDownloadNotification(
      title: 'Downloading',
      body: 'downloading image',
      id: id,
      ongoing: true,
      indeterminate: true,
    );

    final String skin = (widget.operator.skinsList[selectedIndex]['illustId'] as String)
        .replaceFirst('illust_', '');
    final String link = '$kArtRepo/${widget.operator.id}/$skin.png'.githubEncode();

    final downloaderUtils = DownloaderUtils(
      progressCallback: (current, total) {
        final progress = (current / total) * 100;
        notificationService.showDownloadNotification(
          title: 'Downloading',
          body: skin,
          id: id,
          ongoing: true,
          indeterminate: false,
          progress: progress.round(),
        );
      },
      file: File('$path/$skin.png'),
      progress: ProgressImplementation(),
      onDone: () async {
        await notificationService.flutterLocalNotificationsPlugin.cancel(id);
        notificationService.showDownloadNotification(
          title: 'Downloaded',
          body: '$skin finished',
          id: id,
          ongoing: false,
        );
        downloadsBackgroundCores.remove(id.toString());
      },
      deleteOnCancel: true,
      onError: (e) => dev.log('error: $e'),
    );

    DownloaderCore core = await Flowder.download(link, downloaderUtils);
    downloadsBackgroundCores[id.toString()] = core;
  }

  void showSkinInfo() async {
    await showModalBottomSheet<void>(
      constraints: BoxConstraints.loose(
        Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height * 0.75,
        ),
      ),
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final Map skinInfo = widget.operator.skinsList[selectedIndex];
            final Map<String, StyledTextTagBase> tags = ref.watch(styleProvider).tagsAsArknights;
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      skinInfo["displaySkin"]["skinName"] != null
                          ? Text(
                              skinInfo["displaySkin"]["skinName"],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textScaler: const TextScaler.linear(1.5),
                            )
                          : Text(
                              skinInfo["displaySkin"]["skinGroupName"],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textScaler: const TextScaler.linear(1.5),
                            ),
                      skinInfo["skinId"] != null
                          ? Text(
                              skinInfo["skinId"],
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : null,
                      const SizedBox(height: 20),
                      skinInfo["displaySkin"]["modelName"] != null
                          ? Text('Model: ${skinInfo["displaySkin"]["modelName"]}')
                          : null,
                      skinInfo["displaySkin"]["drawerList"] != null
                          ? Text(
                              'Drawer: ${(skinInfo["displaySkin"]["drawerList"] as List).join(', ')}',
                            )
                          : null,
                      skinInfo["displaySkin"]["skinGroupName"] != null
                          ? Text(
                              'Series: ${skinInfo["displaySkin"]["skinGroupName"]}',
                            )
                          : null,
                      const SizedBox(height: 20),
                      skinInfo["displaySkin"]["content"] != null
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 10.0),
                              child: StyledText(
                                text: skinInfo["displaySkin"]["content"],
                                tags: tags,
                                style: TextStyle(
                                  color: skinInfo["displaySkin"]["skinName"] != null
                                      ? Theme.of(context).colorScheme.secondary
                                      : null,
                                ),
                                async: true,
                              ),
                            )
                          : null,
                      skinInfo["displaySkin"]["usage"] != null
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 10.0),
                              child: StyledText(
                                text: skinInfo["displaySkin"]["usage"],
                                tags: tags,
                                async: true,
                              ),
                            )
                          : null,
                      skinInfo["displaySkin"]["description"] != null
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 10.0),
                              child: StyledText(
                                text: skinInfo["displaySkin"]["description"],
                                tags: tags,
                                style: const TextStyle(fontStyle: FontStyle.italic),
                                async: true,
                              ),
                            )
                          : null,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          IconButtonStyled(
                            icon: Icons.file_download_outlined,
                            label: 'Download image',
                            onTap: downloadArt,
                            selected: true,
                          ),
                        ],
                      ),
                    ].nullParser(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> skinChildren = List.generate(widget.operator.skinsList.length, (int index) {
      String avatarLink =
          '$kAvatarRepo/${widget.operator.skinsList[index]['avatarId']}.png'.githubEncode();

      return Container(
        width: 80, //same as height to have a 1:1 box
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            strokeAlign: BorderSide.strokeAlignInside,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              StoredFadeInImage(
                imageUrl: avatarLink,
                filename: '${widget.operator.skinsList[index]['avatarId']}.png',
                type: CacheType.operatorAvatar,
              ),
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => carouselController.animateToPage(
                      index,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    final translucentUi = ref.watch(configProvider.select((p) => p.useTranslucentUi));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          Visibility(
            visible: !chibimode,
            child: IconButton(
              onPressed: () => showSkinInfo(),
              icon: const Icon(Icons.info_outline_rounded),
            ),
          ),
          IconButton(
            onPressed: () => chibify(),
            icon: const Icon(Icons.sync_alt_outlined),
          ),
          Hero(
            tag: 'button',
            child: IconButton(
              onPressed: () => fullscreen(),
              icon: const Icon(Icons.fullscreen),
            ),
          ),
        ],
        flexibleSpace: translucentUi
            ? TranslucentWidget(
                sigma: 3,
                child: Container(color: Colors.transparent),
              )
            : null,
        backgroundColor: translucentUi
            ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5)
            : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ClipRect(
        child: Stack(
          children: [
            Stack(
              children: [
                Visibility(
                  visible: !chibimode,
                  maintainState: true,
                  child: PhotoViewGallery.builder(
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    childEnableAlwaysPan: true,
                    backgroundDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    ),
                    pageController: _pageController,
                    itemCount: widget.operator.skinsList.length,
                    builder: (BuildContext context, int index) {
                      String opSkinId = (widget.operator.skinsList[index]['illustId'] as String)
                          .replaceFirst('illust_', '');
                      return PhotoViewGalleryPageOptions(
                        filterQuality: FilterQuality.high,
                        imageProvider: NetworkToFileImage(
                          url: getImageLink(index),
                          file: LocalDataManager.localCacheFile(
                            '${widget.operator.id}_$opSkinId.png',
                            CacheType.operatorArt,
                          ),
                        ),
                        heroAttributes: PhotoViewHeroAttributes(tag: '$selectedIndex hero'),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: chibimode,
                  maintainState: true,
                  child: const _ChibiView(),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Builder(
                builder: (context) {
                  final double height = 80;
                  final child = Container(
                    margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                    height: height,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceDim
                        .withValues(alpha: translucentUi ? 0.5 : 1),
                    child: CarouselSlider(
                      carouselController: carouselController,
                      items: skinChildren,
                      options: CarouselOptions(
                        onPageChanged: (int index, _) => changeOpSkin(index),
                        enableInfiniteScroll: false,
                        viewportFraction: 0.3,
                      ),
                    ),
                  );

                  return translucentUi ? TranslucentWidget(child: child) : child;
                },
              ),
            ),
            hasDynamicArt && !chibimode
                ? Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 80 + 20,
                        right: 20,
                      ),
                      child: FloatingActionButton.small(
                        onPressed: () {
                          showDynamicSkin();
                        },
                        child: const Icon(Icons.play_arrow),
                      ),
                    ),
                  )
                : null,
          ].nullParser(),
        ),
      ),
    );
  }
}

class FullscreenArtsPage extends StatefulWidget {
  const FullscreenArtsPage(
    this.image, {
    super.key,
    required this.selectedIndex,
    required this.chibi,
  });

  final ImageProvider<Object> image;
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
      DeviceOrientation.landscapeLeft,
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
          Hero(
            tag: 'button',
            child: IconButton(
              onPressed: () => fullscreen(),
              icon: const Icon(Icons.fullscreen_exit),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        leading: const SizedBox(),
      ),
      body: widget.chibi
          ? const Center(
              child: Text('Chibi not supported yet'),
            )
          : PhotoView(
              enablePanAlways: true,
              filterQuality: FilterQuality.high,
              imageProvider: widget.image,
              backgroundDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              heroAttributes: PhotoViewHeroAttributes(tag: '${widget.selectedIndex} hero'),
            ),
    );
  }
}

class _ChibiView extends StatelessWidget {
  const _ChibiView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Chibi not supported yet'),
    );
  }
}
