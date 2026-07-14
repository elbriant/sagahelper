import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/components/saga_empty.dart';
import 'package:sagahelper/components/saga_error.dart';
import 'package:sagahelper/components/shimmer.dart';
import 'package:sagahelper/components/shimmer_loading_mask.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_pool_provider.dart';
import 'package:sagahelper/routes/operators_route.dart' show OperatorListView;

class RecruitmentPage extends ConsumerWidget {
  const RecruitmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<List<String>, List<Operator>> foundTags = {};
    final translucent = ref.watch(configProvider.select((p) => p.useTranslucentUi));
    final loadedPool = ref.watch(recruitPoolProvider);

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

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: const SystemNavBar(),
      appBar: AppBar(
        flexibleSpace: ConditionalTranslucentWidget(
          conditional: translucent,
          child: Container(
            color: translucent ? Colors.transparent : null,
          ),
        ),
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: translucent ? 0.5 : 1),
        title: const Text('Recruitment Calculator'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: loadedPool.when(
            data: (opList) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: foundTags.isNotEmpty
                        ? ListView(
                            children: [],
                          )
                        : OperatorListView(
                            operators: opList,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(onPressed: () {}, child: Text('No tags selected')),
                    ),
                  ),
                ],
              );
            },
            error: (e, _) => SagaError(error: e),
            loading: () {
              return Shimmer(
                linearGradient: shimmerGradient,
                child: Column(
                  children: [
                    Expanded(
                      child: ShimmerLoadingMask(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    ShimmerLoadingMask(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const SizedBox(
                            width: double.maxFinite,
                            child: Text('placeholder'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
