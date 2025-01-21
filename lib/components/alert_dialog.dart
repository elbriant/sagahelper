import 'package:flutter/material.dart';

enum DialogType { normal, dictionary }

Future<void> showAlertDialog({
  required BuildContext context,
  Widget? title,
  Widget? content,
  List<Widget>? actions,
  void Function()? onEndCallback,
  void Function(Object?, StackTrace?)? onErrorCallback,
  DialogType dialogType = DialogType.normal,
}) async {
  assert(title != null || content != null);
  // default
  bool barrierDismissible = true;
  bool useSafeArea = true;
  Widget? icon;

  switch (dialogType) {
    case DialogType.dictionary:
      icon = const Icon(Icons.menu_book_rounded);

    case DialogType.normal:
      break;
  }

  return showDialog<void>(
    context: context,
    useSafeArea: useSafeArea,
    barrierDismissible: barrierDismissible, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        icon: icon,
        title: title,
        content: content,
        actions: actions,
      );
    },
  ).then(
    (_) {
      onEndCallback?.call();
    },
    onError: (e, st) {
      onErrorCallback?.call(e, st);
    },
  );
}
