import 'package:flowder/flowder.dart';
import 'package:flutter/material.dart';

// ----------------- run time flags

Map<String, DownloaderCore> downloadsBackgroundCores = {};
bool flagFirstTimeCheck = false;
bool flagServerFetch = false;
bool flagCheckForAppUpdates = false;

// ------------- constants

const Map<String, Map> credits = {
  "Kengxxiao - ArknightsGameData": {
    "assets": "Providing the raw game data",
    "link": "https://github.com/Kengxxiao/ArknightsGameData",
  },
  "elbriant - Sagapi-assets": {
    "assets": "Various assets from CN data",
    "link": "https://github.com/elbriant/sagapi-assets/",
  },
  "elbriant - Sagapi-audio": {
    "assets": "Operators voicelines",
    "link": "https://github.com/elbriant/sagapi-audio/",
  },
  "Seseren - Twitter/X": {
    "assets": "Saga gifs",
    "link": "https://twitter.com/Seseren_kr",
  },
  "Arknights - hypergryph": {
    "assets":
        "Arknights is a trademark of Hypergryph and Yostar. \n This fan app is not officially affiliated with or endorsed by Hypergryph or Yostar. \n All rights to the Arknights intellectual property belong to their respective owners.",
    "link": "https://ak.hypergryph.com",
  },
};

// Assets from sagapi-assets repo
const String kAvatarRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/charavatars';
const String kSkillRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/skills';
const String kBaseSkillRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/building_skill';
const String kTokenAvatarRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/charavatars';
const String kPortraitRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/charportraits';
const String kArtRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/chararts';
const String kLogoRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/logo';
const String kModImgRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/ui/uniequipimg';
const String kModIconRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/ui/uniequiptype';

// Voice Assets from sagapi-audio repo
const String kVoiceRepo = 'https://github.com/elbriant/sagapi-audio/raw/refs/heads/audio/audio';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
