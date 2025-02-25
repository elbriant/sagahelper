import 'package:flutter/material.dart';
import 'package:sagahelper/components/shimmer.dart';

class ShimmerLoadingMask extends StatefulWidget {
  const ShimmerLoadingMask({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ShimmerLoadingMask> createState() => _ShimmerLoadingMask();
}

class _ShimmerLoadingMask extends State<ShimmerLoadingMask> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shimmerChanges != null) {
      _shimmerChanges!.removeListener(_onShimmerChange);
    }
    _shimmerChanges = Shimmer.of(context)?.shimmerChanges;
    if (_shimmerChanges != null) {
      _shimmerChanges!.addListener(_onShimmerChange);
    }
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    setState(() {
      // Update the shimmer painting.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Collect ancestor shimmer info.
    final shimmer = Shimmer.of(context)!;
    if (!shimmer.isSized) {
      // The ancestor Shimmer widget has not laid
      // itself out yet. Return an empty box.
      return const SizedBox();
    }
    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    Offset offsetWithinShimmer = Offset.zero;
    if (context.findRenderObject() != null) {
      final box = context.findRenderObject() as RenderBox;
      offsetWithinShimmer = shimmer.getDescendantOffset(
        descendant: box,
      );
    }

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}
