import 'package:flutter/material.dart';

/// Reusable card for the Tools page.
///
/// Supports an optional [backgroundImage] asset path and [backgroundAlignment]
/// for the displaced-image effect seen in HomeOrundum.
/// If [backgroundImage] is null, a subtle gradient is used instead.
class ToolCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? child;

  /// Optional asset path for a displaced background image
  /// (e.g. 'assets/orundum.webp'). Leave null for a clean gradient fallback.
  final String? backgroundImage;

  /// Alignment of the background image within the card.
  final Alignment backgroundAlignment;

  const ToolCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.child,
    this.backgroundImage,
    this.backgroundAlignment = const Alignment(-0.8, 0.2),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.35),
                  cs.surfaceContainerHighest.withValues(alpha: 0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Stack(
                children: [
                  if (backgroundImage != null)
                    Positioned.fill(
                      child: Image.asset(
                        backgroundImage!,
                        fit: BoxFit.none,
                        alignment: backgroundAlignment,
                        colorBlendMode: BlendMode.modulate,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  if (backgroundImage != null)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: cs.surface.withValues(alpha: 0.5),
                              spreadRadius: -15,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: child ??
                        Row(
                          children: [
                            if (icon != null) ...[
                              Icon(icon, size: 28, color: cs.primary),
                              const SizedBox(width: 14),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  if (subtitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                          ],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
