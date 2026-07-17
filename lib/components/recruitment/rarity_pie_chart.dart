import 'dart:math';
import 'package:flutter/material.dart';

const List<Color> kRarityPieColors = [
  Color(0xFF9c9c9c), // 0 (unused)
  Color(0xFF9c9c9c), // 1★
  Color(0xFFd8dd5a), // 2★
  Color(0xFF4aabea), // 3★
  Color(0xFFcfc2d1), // 4★
  Color(0xFFf1c644), // 5★
  Color.fromARGB(255, 255, 93, 12), // 6★
];

const String kRarityDisclaimer =
    'Percentages shown are based on operator count only and do not reflect '
    'the game\'s internal probability calculation.';

class RarityPieChart extends StatelessWidget {
  final Map<int, int> rarityCounts;
  final double size;

  const RarityPieChart({
    super.key,
    required this.rarityCounts,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final total = rarityCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return SizedBox(width: size, height: size);

    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _showDetails(context, cs, total),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: _PiePainter(
            rarityCounts: rarityCounts,
            total: total,
            innerRingColor: cs.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, ColorScheme cs, int total) {
    final sortedKeys = rarityCounts.keys.toList()..sort();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Rarity Breakdown',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 130,
                  height: 130,
                  child: CustomPaint(
                    painter: _PiePainter(
                      rarityCounts: rarityCounts,
                      total: total,
                      innerRingColor: cs.surfaceContainerHighest,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...sortedKeys.map((rarity) {
                final count = rarityCounts[rarity]!;
                final pct = (count / total * 100).toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: kRarityPieColors[rarity],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$rarity\u2605', style: const TextStyle(fontSize: 13)),
                      const Spacer(),
                      Text(
                        '$count operators  ($pct%)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              Text(
                kRarityDisclaimer,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final Map<int, int> rarityCounts;
  final int total;
  final Color innerRingColor;

  _PiePainter({
    required this.rarityCounts,
    required this.total,
    required this.innerRingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;
    final sortedKeys = rarityCounts.keys.toList()..sort();

    for (final rarity in sortedKeys) {
      final count = rarityCounts[rarity]!;
      final sweepAngle = 2 * pi * (count / total);

      final paint = Paint()
        ..color = kRarityPieColors[rarity]
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      startAngle += sweepAngle;
    }

    canvas.drawCircle(
      center,
      radius * 0.38,
      Paint()..color = innerRingColor,
    );
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.total != total ||
      old.rarityCounts != rarityCounts ||
      old.innerRingColor != innerRingColor;
}
