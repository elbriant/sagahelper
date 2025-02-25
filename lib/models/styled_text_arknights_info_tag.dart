import 'package:flutter/gestures.dart';
import 'package:styled_text/styled_text.dart';

/// Callback to an action called from a style (for example, tapping text inside a style).
typedef StyledTextTagOnTapGeneratorCallback = void Function(
  String? text,
  Map<String?, String?> attributes,
)?
    Function(String? text, Map<String?, String?> attributes);

/// A custom text style, for which you can specify the processing of attributes of the tag and if has a gesture handler.
class StyledTextArknightsInfoTag extends StyledTextCustomTag {
  /// A callback to be called when the tag is tapped.
  final StyledTextTagOnTapGeneratorCallback? onTapGenerator;

  const StyledTextArknightsInfoTag({
    required super.parse,
    super.baseStyle,
    this.onTapGenerator,
  });

  @override
  GestureRecognizer? createRecognizer(String? text, Map<String?, String?> attributes) {
    final onTap = onTapGenerator?.call(text, attributes);

    if (onTap != null) {
      return TapGestureRecognizer()..onTap = () => onTap(text, attributes);
    }
    return null;
  }
}
