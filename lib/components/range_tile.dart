import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sagahelper/global_data.dart';
import 'package:sagahelper/providers/cache_provider.dart';

class RangeTile extends StatelessWidget {
  const RangeTile({super.key, required this.rangeGrids, this.isSmall = false});
  final List rangeGrids;
  final bool isSmall;

  factory RangeTile.smol(String rangeId) {
    return RangeTile(
      rangeGrids: NavigationService.navigatorKey.currentContext!
          .read<CacheProvider>()
          .cachedRangeTable![rangeId]["grids"],
      isSmall: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    int maxRowPos = 0;
    int maxColPos = 0;
    int maxRowNeg = 0; // Row offset
    int maxColNeg = 0; // Col offset

    for (Map tile in rangeGrids) {
      if (tile['row'] > maxRowPos) maxRowPos = tile['row'];
      if (tile['row'] < maxRowNeg) maxRowNeg = tile['row'];
      if (tile['col'] > maxColPos) maxColPos = tile['col'];
      if (tile['col'] < maxColNeg) maxColNeg = tile['col'];
    }

    // has to add 1 as offset because 0 is no-existen column/row
    // so in this case the offset should be XOffset = 1+XNeg
    int tileRowOffset = 1 + maxRowNeg.abs();
    int tileColOffset = 1 + maxColNeg.abs();
    int cols = maxColPos + tileColOffset;
    int rows = maxRowPos + tileRowOffset;

    List<Widget> finishedRange = List.generate(
      cols * rows, (index) => const SizedBox.square(dimension: 2), // void
    );
    for (Map tile in rangeGrids) {
      int position = cols * ((tile['row'] as int) + tileRowOffset - 1) +
          ((tile['col'] as int) + tileColOffset);
      finishedRange[position - 1] = SizedBox.square(
        dimension: 2,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              strokeAlign: BorderSide.strokeAlignInside,
              width: 2,
            ),
          ),
        ),
      );
    }
    // 0 - 0 char
    finishedRange[cols * (tileRowOffset - 1) + tileColOffset - 1] = SizedBox.square(
      dimension: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ); // player

    final gridPadding = isSmall
        ? max(
            finishedRange.length < 20.0
                ? 16.0 -
                    finishedRange.length +
                    (rows > 2 ? 12.0 : 0.0) +
                    (finishedRange.length == 2 ? 12.0 : 0.0) +
                    (finishedRange.length == 1 ? 18.0 : 0.0) +
                    (rows > 4 ? 12.0 : 0.0)
                : 40.0 - finishedRange.length + (rows > 5 ? 14.0 : 0.0),
            0.0,
          )
        : max(
            finishedRange.length < 20.0
                ? 30.0 -
                    finishedRange.length +
                    (rows > 2 ? 12.0 : 0.0) +
                    (rows > 4 ? 12.0 : 0.0) +
                    (finishedRange.length == 2 ? 12.0 : 0.0) +
                    (finishedRange.length == 1 ? 18.0 : 0.0)
                : 48.0 - finishedRange.length,
            0.0,
          );

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: isSmall ? 90 : MediaQuery.sizeOf(context).width / 3,
          width: isSmall ? 90 : 120,
          margin: EdgeInsets.only(bottom: isSmall ? 12.0 : 8.0, top: isSmall ? 8.0 : 0.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              width: 4.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    padding: EdgeInsets.fromLTRB(
                      gridPadding,
                      8.0,
                      gridPadding,
                      12.0,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: finishedRange,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
          ),
          child: Text(
            'Range',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w900,
            ),
            // ignore: deprecated_member_use
            textScaler: TextScaler.linear(
              // ignore: deprecated_member_use
              MediaQuery.textScalerOf(context).textScaleFactor + 0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
