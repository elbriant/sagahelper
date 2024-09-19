import 'package:autoscale_tabbarview/autoscale_tabbarview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:docsprts/pages/operators_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docsprts/providers/ui_provider.dart';
import 'package:docsprts/components/traslucent_ui.dart';
import 'package:sliver_tools/sliver_tools.dart';

class OperatorInfo extends StatelessWidget {
  final Operator operator;
  const OperatorInfo(this.operator, {super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: TabBarView(
            children: <Widget>[
              ArchivePage(operator),
              ArtPage(operator),
              VoicePage(operator),
            ],
          ),
          bottomNavigationBar: const TabBar(
            dividerColor: Colors.transparent,
            tabs: <Widget>[
              Tab(text: 'Archive', icon: Icon(Icons.file_present)),
              Tab(text: 'Art', icon: Icon(Icons.filter)),
              Tab(text: 'Voice', icon: Icon(Icons.voice_chat)),
            ],
          ),
        ),
      )
    );
  }
}

// -------------------- Archive

class HeaderInfo extends StatelessWidget {
  const HeaderInfo({super.key, required this.operator});
  final Operator operator;

  @override
  Widget build(BuildContext context) {

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
              const SizedBox(height: 145),
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('some info XD', style: Theme.of(context).brightness == Brightness.dark ? const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 6)]) : null),
                        Text('${operator.displayNumber} / ${operator.id}', style: Theme.of(context).brightness == Brightness.dark ? const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 6)]) : null,)
                      ],
                    )
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(operator.itemUsage),
              ),
              Wrap(
                spacing: 12.0,
                children: List.generate(operator.tagList.length+1, (indx) {
                  if (indx == 0) {
                    return ActionChip(label: Text(operator.position), side: BorderSide(color: operator.position == 'RANGED' ? Colors.yellow[600]! : Colors.red), onPressed: (){});
                  }
                  return ActionChip(label: Text(operator.tagList[indx-1]), side: BorderSide(color: Theme.of(context).colorScheme.tertiary), onPressed: (){});
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
  const LoreInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 600,
      child: Center(child: Text('here lore things'),)
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
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    HeaderInfo(operator: operator),
                    const DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar.secondary(
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(text: 'Lore'),
                              Tab(text: 'Skills'),
                            ]
                          ),
                          AutoScaleTabBarView(
                            children: [
                              LoreInfo(),
                              SkillInfo()
                            ]
                          )
                        ],
                      )
                    )
                  ]
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

class ArtPage extends StatelessWidget {
  final Operator operator;
  const ArtPage(this.operator, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3, child: Container(color: Colors.transparent, child: FlexibleSpaceBar(title: Text(operator.name), titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)))) : FlexibleSpaceBar(title: Text(operator.name), titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)),
          backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(onPressed: (){}, icon: const Icon(Icons.fullscreen))
          ], 
        )
      ],
    );
  }
}

// --------------------------- Voice

class VoicePage extends StatelessWidget {
  final Operator operator;
  const VoicePage(this.operator, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          flexibleSpace: context.read<UiProvider>().useTranslucentUi == true ? TranslucentWidget(sigma: 3, child: Container(color: Colors.transparent, child: FlexibleSpaceBar(title: Text(operator.name), titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)))) : FlexibleSpaceBar(title: Text(operator.name), titlePadding: const EdgeInsets.only(left: 72.0, bottom: 16.0, right: 32.0)),
          backgroundColor: context.read<UiProvider>().useTranslucentUi == true ? Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5) : null,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        )
      ],
    );
  }
}
