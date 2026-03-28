import 'package:flutter/material.dart';
import 'package:sagahelper/core/navigation_service.dart';

enum SnackBarType { normal, success, failure, warning, custom }

class SnackBarService {
  static void showSnackBar(
    String? text, {
    SnackBarType type = SnackBarType.normal,
    SnackBar? snackbar,
  }) {
    switch (type) {
      case SnackBarType.normal:
        assert(text != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
            .showSnackBar(SnackBar(content: Text(text!)));
        break;
      case SnackBarType.success:
        assert(text != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.done, color: Colors.green[700]),
                Text(text!),
              ],
            ),
            backgroundColor: Colors.green[50],
          ),
        );
        break;
      case SnackBarType.failure:
        assert(text != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Theme.of(NavigationService.navigatorKey.currentContext!).colorScheme.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text!,
                    style: TextStyle(
                      color: Theme.of(
                        NavigationService.navigatorKey.currentContext!,
                      ).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor:
                Theme.of(NavigationService.navigatorKey.currentContext!).colorScheme.errorContainer,
          ),
        );
        break;
      case SnackBarType.warning:
        assert(text != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.amber[600]),
                Text(text!),
              ],
            ),
            backgroundColor: Colors.amber[100],
          ),
        );
        break;
      case SnackBarType.custom:
        assert(snackbar != null);
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
            .showSnackBar(snackbar!);
        break;
    }
  }
}
