import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sagahelper/components/custom_tabbar.dart';
import 'package:sagahelper/components/shimmer.dart';
import 'package:sagahelper/components/shimmer_loading_mask.dart';
import 'package:sagahelper/components/stored_image.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/pages/operator/archive_page.dart';
import 'package:sagahelper/pages/operator/art_page.dart';
import 'package:sagahelper/pages/operator/voice_page.dart';
import 'package:sagahelper/providers/settings_provider.dart';
import 'package:sagahelper/providers/ui_provider.dart';

Future<Widget> buildOperatorInfo(operator) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return OperatorInfo(
    key: const Key('Ops2'),
    operator: operator,
  );
}

class OperatorInfoSkeletonPage extends StatelessWidget {
  final Operator operator;
  const OperatorInfoSkeletonPage({
    super.key,
    required this.operator,
  });

  @override
  Widget build(BuildContext context) {
    final backColor = Theme.of(context).colorScheme.surfaceContainer;
    final frontColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    final shimmerGradient = LinearGradient(
      colors: [
        backColor,
        frontColor,
        backColor,
      ],
      stops: [
        0.1,
        0.3,
        0.4,
      ],
      begin: const Alignment(-1.0, -0.3),
      end: const Alignment(1.0, 0.3),
      tileMode: TileMode.clamp,
    );

    return Shimmer(
      linearGradient: shimmerGradient,
      child: FutureBuilder(
        future: buildOperatorInfo(operator),
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: snapshot.hasData
                ? snapshot.data!
                : OperatorInfoPlaceholder(
                    operator: operator,
                  ),
          );
        },
      ),
    );
  }
}

class OperatorInfo extends StatelessWidget {
  const OperatorInfo({
    super.key,
    required this.operator,
  });
  final Operator operator;

  @override
  Widget build(BuildContext context) {
    final transparent = context.read<UiProvider>().useTranslucentUi;

    List<Tab> tabs = <Tab>[
      const Tab(text: 'Archive', icon: Icon(Icons.file_present)),
      const Tab(text: 'Art', icon: Icon(Icons.filter)),
      const Tab(text: 'Voice', icon: Icon(Icons.voice_chat)),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        extendBody: true,
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            ArchivePage(operator),
            ArtPage(operator),
            VoicePage(operator),
          ],
        ),
        bottomNavigationBar: CustomTabBar(
          tabs: tabs,
          isTransparent: transparent,
        ),
      ),
    );
  }
}

class OperatorInfoPlaceholder extends StatelessWidget {
  final Operator operator;
  const OperatorInfoPlaceholder({super.key, required this.operator});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            flexibleSpace: context.read<UiProvider>().useTranslucentUi == true
                ? TranslucentWidget(
                    child: FlexibleSpaceBar(
                      title: Text(operator.name),
                      titlePadding: const EdgeInsets.only(
                        left: 72.0,
                        bottom: 16.0,
                        right: 32.0,
                      ),
                    ),
                  )
                : FlexibleSpaceBar(
                    title: Text(operator.name),
                    titlePadding: const EdgeInsets.only(
                      left: 72.0,
                      bottom: 16.0,
                      right: 32.0,
                    ),
                  ),
            backgroundColor: context.read<UiProvider>().useTranslucentUi == true
                ? Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5)
                : null,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              MenuAnchor(
                menuChildren: [],
                builder: (
                  BuildContext context,
                  MenuController controller,
                  Widget? child,
                ) {
                  return IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz),
                  );
                },
              ),
            ],
          ),
          SliverList.list(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              margin: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.5),
                                    offset: Offset(0, 8.0),
                                    blurRadius: 10.0,
                                  ),
                                ],
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  width: 4.0,
                                  style: BorderStyle.solid,
                                ),
                                color: const Color.fromARGB(255, 241, 241, 241),
                              ),
                              child: StoredImage(
                                heroTag: operator.id,
                                filePath:
                                    'images/${operator.id}_dl${DisplayList.avatar.index.toString()}.png',
                                fit: BoxFit.fitWidth,
                                placeholder: Image.asset(
                                  'assets/placeholders/avatar.png',
                                  colorBlendMode: BlendMode.modulate,
                                  color: Colors.transparent,
                                  fit: BoxFit.fitWidth,
                                  key: const Key('placeholder'),
                                ),
                                imageUrl: '$kAvatarRepo/${operator.id}.png',
                                showProgress: false,
                                useSync: true,
                              ),
                            ),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    ShimmerLoadingMask(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              width: 128,
                              height: 14,
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              width: double.maxFinite,
                              height: 14,
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              width: 86,
                              height: 14,
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              width: double.maxFinite,
                              height: 14,
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              width: 64,
                              height: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ShimmerLoadingMask(
                      child: Wrap(
                        spacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            width: 82,
                            height: 34,
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            width: 82,
                            height: 34,
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            width: 82,
                            height: 34,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ShimmerLoadingMask(
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          width: 62,
                          height: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          width: 62,
                          height: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 20),
            ],
          ),
          SliverToBoxAdapter(
            child: ShimmerLoadingMask(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8.0, left: 28.0, top: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    width: 82,
                    height: 46,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 28.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    width: double.maxFinite,
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ShimmerLoadingMask(
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          width: MediaQuery.sizeOf(context).width,
          height: 128,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
