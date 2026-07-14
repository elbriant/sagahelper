import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/components/recruitment/recruit_combo_container.dart';
import 'package:sagahelper/components/recruitment/recruit_operator_container.dart';
import 'package:sagahelper/components/recruitment/recruit_tags_bottom_sheet.dart';
import 'package:sagahelper/components/saga_error.dart';
import 'package:sagahelper/components/shimmer.dart';
import 'package:sagahelper/components/shimmer_loading_mask.dart';
import 'package:sagahelper/components/traslucent_ui.dart';
import 'package:sagahelper/models/recruit_operator.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_pool_provider.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_results_provider.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_selected_tags_provider.dart';
import 'package:sagahelper/providers/tools/recruitment/recruit_tag_map_provider.dart';

class RecruitmentPage extends ConsumerWidget {
  const RecruitmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translucent = ref.watch(configProvider.select((p) => p.useTranslucentUi));
    final loadedPool = ref.watch(recruitPoolProvider);
    final selectedTags = ref.watch(recruitSelectedTagsProvider);
    final hasResults = selectedTags.isNotEmpty;

    final backColor = Theme.of(context).colorScheme.surfaceContainer;
    final frontColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final shimmerGradient = LinearGradient(
      colors: [backColor, frontColor, backColor],
      stops: const [0.1, 0.3, 0.4],
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
                    child: hasResults
                        ? const _RecruitResultsView()
                        : _RecruitPoolView(recruitOps: opList),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildTagButton(context, ref, selectedTags),
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

  Widget _buildTagButton(
    BuildContext context,
    WidgetRef ref,
    RecruitSelectedTags selectedTags,
  ) {
    final tagMapAsync = ref.watch(recruitTagMapProvider);

    String buttonLabel;
    if (selectedTags.isEmpty) {
      buttonLabel = 'Select tags';
    } else {
      final tagNames = tagMapAsync.whenOrNull(
            data: (tagMap) =>
                selectedTags.tagStack.map((id) => tagMap[id]?.tagName).whereType<String>().toList(),
          ) ??
          [];
      buttonLabel = tagNames.join(' + ');
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedTags.isNotEmpty ? Theme.of(context).colorScheme.primaryContainer : null,
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: () => _showTagSheet(context, ref),
        child: Text(
          buttonLabel,
          style: TextStyle(
            color:
                selectedTags.isNotEmpty ? Theme.of(context).colorScheme.onPrimaryContainer : null,
          ),
        ),
      ),
    );
  }

  void _showTagSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      enableDrag: true,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              children: const [
                RecruitTagsBottomSheet(),
              ],
            );
          },
        );
      },
    );
  }
}

class _RecruitPoolView extends StatelessWidget {
  final List<RecruitOperator> recruitOps;

  const _RecruitPoolView({required this.recruitOps});

  @override
  Widget build(BuildContext context) {
    // Sort: rarity desc first, then most tags
    final sorted = List<RecruitOperator>.from(recruitOps)
      ..sort((a, b) {
        final rarityCmp = b.op.rarity.compareTo(a.op.rarity);
        if (rarityCmp != 0) return rarityCmp;
        return b.allTagIds.length.compareTo(a.allTagIds.length);
      });

    return ListView(
      padding: EdgeInsets.fromLTRB(
        0,
        MediaQuery.paddingOf(context).top + 4.0,
        0,
        MediaQuery.paddingOf(context).bottom + 80.0,
      ),
      children: [
        // All pool operators in a consistent container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(120),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withAlpha(60),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Text(
                  'Recruitment Pool (${sorted.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              // Operator grid
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sorted.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemBuilder: (context, index) {
                    return RecruitOperatorContainer(recruitOp: sorted[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecruitResultsView extends ConsumerWidget {
  const _RecruitResultsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(recruitResultsProvider);
    final tagMapAsync = ref.watch(recruitTagMapProvider);

    return resultsAsync.when(
      data: (combos) {
        if (combos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No combinations found',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return tagMapAsync.when(
          data: (tagMap) => ListView.builder(
            padding: EdgeInsets.fromLTRB(
              0,
              MediaQuery.paddingOf(context).top + 4.0,
              0,
              MediaQuery.paddingOf(context).bottom + 80.0,
            ),
            itemCount: combos.length,
            itemBuilder: (context, index) {
              return RecruitComboContainer(
                combo: combos[index],
                tagMap: tagMap,
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
