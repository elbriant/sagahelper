import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/components/saga_error.dart';
import 'package:sagahelper/components/operator_route/op_route_filters_popup.dart';
import 'package:sagahelper/components/operator_route/op_route_loading.dart';
import 'package:sagahelper/components/operator_route/op_route_search_not_found.dart';
import 'package:sagahelper/components/operator_info_page/operator_container.dart';
import 'package:sagahelper/models/config/types.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/providers/cache_provider.dart';
import 'package:sagahelper/providers/config_provider.dart';
import 'package:sagahelper/providers/operator_list_provider.dart';
import 'package:sagahelper/providers/operator_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/components/traslucent_ui.dart';

class OperatorsPage extends ConsumerStatefulWidget {
  const OperatorsPage({super.key});

  @override
  ConsumerState<OperatorsPage> createState() => _OperatorsPageState();
}

class _OperatorsPageState extends ConsumerState<OperatorsPage> {
  late final TextEditingController _textController;
  late final MenuController _menuController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _menuController = MenuController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void reloadgamedata() {
    ref.invalidate(cacheProvider);
    ref.invalidate(operatorListProvider);
    _menuController.close();
  }

  void showFilters() {
    showModalBottomSheet<void>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      enableDrag: true,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return const OpRouteFiltersPopup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = ref.watch(operatorSearchProvider.select((p) => p.isSearching));
    final atLeastOneFilter =
        ref.watch(operatorSearchProvider.select((p) => p.operatorFilters.isNotEmpty));
    final translucent = ref.watch(configProvider.select((p) => p.useTranslucentUi));
    final filteredOperatorList = ref.watch(filteredOperatorListProvider);
    final isFreshOperatorData = !filteredOperatorList.isLoading && filteredOperatorList.hasValue;

    return Scaffold(
      extendBody: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: isSearching
            ? TextField(
                autofocus: true,
                textAlignVertical: TextAlignVertical.center,
                controller: _textController,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search_off),
                    onPressed: () {
                      _textController.text = '';
                      ref.read(operatorSearchProvider.notifier)
                        ..searchString = ''
                        ..isSearching = false;
                    },
                  ),
                  hintText: 'Search...',
                  border: const UnderlineInputBorder(),
                ),
                onChanged: (value) =>
                    ref.read(operatorSearchProvider.notifier).searchString = value,
                onSubmitted: (value) =>
                    ref.read(operatorSearchProvider.notifier).searchString = value,
              )
            : const Text('Operators'),
        flexibleSpace: ConditionalTranslucentWidget(
          conditional: translucent,
          child: Container(
            color: translucent ? Colors.transparent : null,
          ),
        ),
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: translucent ? 0.5 : 1),
        actions: [
          if (!isSearching)
            IconButton(
              onPressed: () => ref.read(operatorSearchProvider.notifier).isSearching = true,
              icon: const Icon(Icons.search),
              tooltip: 'search operator',
            ),
          IconButton(
            onPressed: isFreshOperatorData ? showFilters : null,
            icon: Icon(
              Icons.filter_list,
              color: atLeastOneFilter ? Colors.amberAccent[400] : null,
            ),
            tooltip: 'Show filters',
          ),
          MenuAnchor(
            menuChildren: [
              ListTile(
                title: const Text('reload gamedata'),
                onTap: reloadgamedata,
                enabled: !filteredOperatorList.isLoading,
              ),
            ],
            controller: _menuController,
            builder: (
              BuildContext context,
              MenuController controller,
              Widget? child,
            ) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_vert),
                tooltip: 'Show menu',
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: switch (filteredOperatorList) {
          // loading
          AsyncValue(isLoading: true) => const OpRouteLoading(),
          // error
          AsyncValue(:final error?) => SagaError(error: error),
          // done
          AsyncValue<List<Operator>>(:final value?) =>
            value.isEmpty ? const OpRouteSearchNotFound() : OperatorListView(operators: value),
          // fallback
          _ => const OpRouteLoading(),
        },
      ),
    );
  }
}

class OperatorListView extends ConsumerWidget {
  final List<Operator> operators;
  const OperatorListView({super.key, required this.operators});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchDelegate = ref.watch(configProvider.select((p) => p.operatorSearchDelegate));
    final opDisplay = ref.watch(configProvider.select((p) => p.operatorDisplayMode));

    return RawScrollbar(
      thickness: 12,
      interactive: true,
      radius: const Radius.circular(12),
      minThumbLength: 48,
      mainAxisMargin: 4,
      thumbColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
      child: GridView.builder(
        itemCount: operators.length,
        addAutomaticKeepAlives: true,
        cacheExtent: (2000 * searchDelegate).toDouble(),
        padding: EdgeInsets.fromLTRB(
          4.0,
          MediaQuery.paddingOf(context).top + 4.0,
          4.0,
          MediaQuery.paddingOf(context).bottom + 4.0,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: searchDelegate,
          childAspectRatio: switch (opDisplay) {
            OperatorDisplayMode.portrait => 0.54,
            OperatorDisplayMode.avatar => 1.0,
          },
        ),
        itemBuilder: (context, index) => OperatorContainer(index: index, op: operators[index]),
      ),
    );
  }
}
