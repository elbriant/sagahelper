import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/material.dart';
import 'package:pretty_diff_text/src/diff_cleanup_type.dart';

class PrettyDiffText extends StatelessWidget {
  /// The original text which is going to be compared with [newText].
  final String oldText;

  /// Edited text which is going to be compared with [oldText].
  final String newText;

  /// show old text diff
  final bool showInsertedText;

  /// show new text diff
  final bool showDeletedText;

  /// Default text style of RichText. Mainly will be used for the text which did not change.
  /// [addedTextStyle] and [deletedTextStyle] will inherit styles from it.
  final TextStyle defaultTextStyle;

  /// Text style of text which was added.
  final TextStyle addedTextStyle;

  /// Text style of text which was deleted.
  final TextStyle deletedTextStyle;

  /// See [DiffCleanupType] for types.
  final DiffCleanupType diffCleanupType;

  /// If the mapping phase of the diff computation takes longer than this,
  /// then the computation is truncated and the best solution to date is
  /// returned. While guaranteed to be correct, it may not be optimal.
  /// A timeout of '0' allows for unlimited computation.
  /// The default value is 1.0.
  final double diffTimeout;

  /// Cost of an empty edit operation in terms of edit characters.
  /// This value is used when [DiffCleanupType] is selected as [DiffCleanupType.EFFICIENCY]
  /// The larger the edit cost, the more aggressive the cleanup.
  /// The default value is 4.
  final int diffEditCost;

  /// !!! DERIVED PROPERTIES FROM FLUTTER'S [RichText] IN ORDER TO ALLOW CUSTOMIZABILITY !!!
  /// See [RichText] for documentation.
  ///
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const PrettyDiffText({
    super.key,
    required this.oldText,
    required this.newText,
    this.showInsertedText = true,
    this.showDeletedText = true,
    this.defaultTextStyle = const TextStyle(color: Colors.black),
    this.addedTextStyle = const TextStyle(
      backgroundColor: Color.fromARGB(255, 139, 197, 139),
    ),
    this.deletedTextStyle = const TextStyle(
      backgroundColor: Color.fromARGB(255, 255, 129, 129),
      decoration: TextDecoration.lineThrough,
    ),
    this.diffTimeout = 1.0,
    this.diffCleanupType = DiffCleanupType.SEMANTIC,
    this.diffEditCost = 4,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  });

  /// Returns a [String] with markup etiquettes
  /// <diffInsert> if is inserted text
  /// <diffDelete> if is deleted text
  /// else is just returned as is
  static String getJustStringAsMarkup({
    required String oldText,
    required String newText,
    bool showInsertedText = true,
    bool showDeletedText = true,
    double diffTimeout = 1.0,
    DiffCleanupType diffCleanupType = DiffCleanupType.SEMANTIC,
    int diffEditCost = 4,
  }) {
    assert(showInsertedText == true || showDeletedText == true);
    var result = '';
    DiffMatchPatch dmp = DiffMatchPatch();
    dmp.diffTimeout = diffTimeout;
    dmp.diffEditCost = diffEditCost;
    List<Diff> diffs = dmp.diff(oldText, newText);
    cleanupDiffs(dmp, diffs, diffCleanupType);

    for (Diff diff in diffs) {
      if (diff.operation == DIFF_EQUAL) {
        result += diff.text;
      } else if (diff.operation == DIFF_INSERT) {
        if (!showInsertedText) continue;
        result += '<diffInsert>${diff.text}</diffInsert>';
      } else if (diff.operation == DIFF_DELETE) {
        if (!showDeletedText) continue;
        result += '<diffDelete>${diff.text}</diffDelete>';
      } else {
        throw "Unknown diff operation. Diff operation should be one of: [DIFF_INSERT], [DIFF_DELETE] or [DIFF_EQUAL].";
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    assert(showInsertedText == true || showDeletedText == true);
    DiffMatchPatch dmp = DiffMatchPatch();
    dmp.diffTimeout = diffTimeout;
    dmp.diffEditCost = diffEditCost;
    List<Diff> diffs = dmp.diff(oldText, newText);

    cleanupDiffs(dmp, diffs, diffCleanupType);

    final textSpans = List<TextSpan>.empty(growable: true);

    for (Diff diff in diffs) {
      if (diff.operation == DIFF_INSERT && showInsertedText ||
          diff.operation == DIFF_DELETE && showDeletedText ||
          diff.operation == DIFF_EQUAL) {
        TextStyle? textStyle = getTextStyleByDiffOperation(diff);
        textSpans.add(TextSpan(text: diff.text, style: textStyle));
      }
    }

    return RichText(
      text: TextSpan(
        text: '',
        style: defaultTextStyle,
        children: textSpans,
      ),
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      textScaler: TextScaler.linear(textScaleFactor),
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }

  TextStyle getTextStyleByDiffOperation(Diff diff) {
    switch (diff.operation) {
      case DIFF_INSERT:
        return addedTextStyle;

      case DIFF_DELETE:
        return deletedTextStyle;

      case DIFF_EQUAL:
        return defaultTextStyle;

      default:
        throw "Unknown diff operation. Diff operation should be one of: [DIFF_INSERT], [DIFF_DELETE] or [DIFF_EQUAL].";
    }
  }

  static void cleanupDiffs(DiffMatchPatch dmp, List<Diff> diffs, DiffCleanupType diffCleanupType) {
    switch (diffCleanupType) {
      case DiffCleanupType.SEMANTIC:
        dmp.diffCleanupSemantic(diffs);
        break;
      case DiffCleanupType.EFFICIENCY:
        dmp.diffCleanupEfficiency(diffs);
        break;
      case DiffCleanupType.NONE:
        // No clean up, do nothing.
        break;
      default:
        throw "Unknown DiffCleanupType. DiffCleanupType should be one of: [SEMANTIC], [EFFICIENCY] or [NONE].";
    }
  }
}
