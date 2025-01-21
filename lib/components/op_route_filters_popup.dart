import 'package:contentsize_tabbarview/contentsize_tabbarview.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/components/op_route_filters_appareance.dart';
import 'package:sagahelper/components/op_route_filters_filtering.dart';
import 'package:sagahelper/components/op_route_filters_sorting.dart';

class OpRouteFiltersPopup extends StatelessWidget {
  const OpRouteFiltersPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TabBar(
              tabs: <Widget>[
                Tab(text: 'Filters'),
                Tab(text: 'Order'),
                Tab(text: 'Appareance'),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints.loose(
                Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height * 0.65,
                ),
              ),
              child: const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ContentSizeTabBarView(
                    children: <Widget>[
                      OpRouteFiltersFiltering(),
                      OpRouteFiltersSorting(),
                      OpRouteFiltersAppareance(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
