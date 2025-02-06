import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sagahelper/components/styled_buttons.dart';

typedef SliderSelectorBuilderCallback = Widget Function(int index, BuildContext context);

class SliderSelector extends StatefulWidget {
  const SliderSelector({
    super.key,
    required this.length,
    required this.currentIndex,
    required this.onValueChanged,
    required this.builder,
  });

  final int length;
  final int currentIndex;

  final ValueChanged<int> onValueChanged;
  final SliderSelectorBuilderCallback builder;

  @override
  State<SliderSelector> createState() => _SliderSelectorState();
}

class _SliderSelectorState extends State<SliderSelector> {
  late final CarouselSliderController _carouselController;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              scrollDirection: Axis.vertical,
              onPageChanged: (int index, _) => widget.onValueChanged.call(index),
              enableInfiniteScroll: false,
              reverse: true,
              aspectRatio: 1,
              viewportFraction: 1.0,
            ),
            items: List.generate(
              widget.length,
              (int index) {
                return Center(
                  child: widget.builder.call(index, context),
                );
              },
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility.maintain(
              visible: widget.currentIndex != widget.length - 1,
              child: LilButton(
                icon: const Icon(Icons.arrow_drop_up_rounded),
                fun: () => _carouselController.animateToPage(
                  widget.currentIndex + 1,
                  curve: Curves.easeOutCubic,
                ),
                padding: const EdgeInsets.all(0.0),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
            Visibility.maintain(
              visible: widget.currentIndex != 0,
              child: LilButton(
                icon: const Icon(Icons.arrow_drop_down_rounded),
                fun: () => _carouselController.animateToPage(
                  widget.currentIndex - 1,
                  curve: Curves.easeOutCubic,
                ),
                padding: const EdgeInsets.all(0.0),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
