import 'package:flutter/services.dart';

class AssetService {
  static late final List<String> assets;
  static Set<String> get assetSet => assets.toSet();

  static init() async {
    final manifestContent = await AssetManifest.loadFromAssetBundle(rootBundle);
    assets = manifestContent.listAssets();
  }
}
