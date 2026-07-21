import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sagahelper/components/home/home_title.dart';
import 'package:sagahelper/models/announcement.dart';
import 'package:sagahelper/providers/announcement_provider.dart';
import 'package:sagahelper/utils/misc.dart';
import 'package:webview_flutter/webview_flutter.dart';

bool get _canUseWebView => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

class HomeAnnouncements extends ConsumerWidget {
  const HomeAnnouncements({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementProvider);

    return announcementsAsync.when(
      loading: () => const _AnnouncementsLoading(),
      error: (_, __) => const SizedBox.shrink(),
      data: (meta) {
        if (meta == null) return const SizedBox.shrink();

        final announcements = meta.filteredAnnouncements;

        if (announcements.isEmpty) return const SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeTitle(label: 'News'),
            const SizedBox(height: 8.0),
            ...announcements.map((a) {
              if (a.isImageOnly && a.extractedImageUrl != null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _ImageAnnouncementCard(
                    announcement: a,
                    imageUrl: a.extractedImageUrl!,
                    onTap: () => _openImageViewer(
                      context,
                      a.extractedImageUrl!,
                      a.title,
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _ContentAnnouncementCard(
                  announcement: a,
                  onTap: () => _openContent(context, a.webUrl, a.title),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _openImageViewer(BuildContext context, String imageUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ImageViewerPage(imageUrl: imageUrl, title: title),
      ),
    );
  }

  void _openContent(BuildContext context, String url, String title) {
    if (_canUseWebView) {
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => _WebViewPage(url: url, title: title),
        ),
      );
    } else {
      openUrl(url);
    }
  }
}

class _ImageViewerPage extends StatelessWidget {
  const _ImageViewerPage({required this.imageUrl, required this.title});

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        minScale: PhotoViewComputedScale.contained / 2,
        maxScale: PhotoViewComputedScale.covered * 3,
        enablePanAlways: true,
      ),
    );
  }
}

class _WebViewPage extends StatefulWidget {
  const _WebViewPage({required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<_WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<_WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress / 100);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

class _ImageAnnouncementCard extends StatelessWidget {
  const _ImageAnnouncementCard({
    required this.announcement,
    required this.imageUrl,
    required this.onTap,
  });

  final Announcement announcement;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.fitWidth,
                width: double.maxFinite,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentAnnouncementCard extends StatelessWidget {
  const _ContentAnnouncementCard({
    required this.announcement,
    required this.onTap,
  });

  final Announcement announcement;
  final VoidCallback onTap;

  Color _getGroupColor() {
    switch (announcement.group) {
      case 'ACTIVITY':
        return const Color(0xFF7E57C2);
      case 'SYSTEM':
        return const Color(0xFF42A5F5);
      default:
        return const Color(0xFF78909C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getGroupColor(),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        announcement.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announcement.group,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementsLoading extends StatelessWidget {
  const _AnnouncementsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeTitle(label: 'News'),
        const SizedBox(height: 8.0),
        ...List.generate(
          2,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              width: double.maxFinite,
              height: 160,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
