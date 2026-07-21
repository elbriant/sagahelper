import 'package:flowder/flowder.dart';
import 'package:sagahelper/providers/server_provider.dart';

/// todo list
/// TODO: feature: show "new" badge on current version added operators
/// TODO: put ak news on home page

/// bug list
/// TODO: main cn server (¿¿??) (maybe home screen)

// ----------------- run time flags

Map<String, DownloaderCore> downloadsBackgroundCores = {};
bool flagFirstTimeCheck = false;
bool flagCheckForAppUpdates = false;

// ------------- constants

const String appVersion = "Beta 0.3.0";

const Map<String, Map> credits = {
  "elbriant - Sagapi-gamedata": {
    "assets": "Providing the raw game data",
    "link": "https://github.com/elbriant/sagapi-gamedata",
  },
  "Kengxxiao - ArknightsGameData": {
    "assets": "Providing the raw game data for cn",
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

// yes, i use github as a CDN
// maybe i'll consider to use Statically or something later

// gamedata from ArknightsGamedata repo
String gamedataRepo(Server s) => switch (s) {
      Server.cn =>
        'https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/refs/heads/master/zh_CN/gamedata',
      _ =>
        'https://raw.githubusercontent.com/elbriant/sagapi-gamedata/refs/heads/gamedata/${s.repoString}/gamedata'
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
const String kSubProfessionIconRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/ui/subprofessionicon';
const String kSkinBrandLogoRepo =
    'https://raw.githubusercontent.com/elbriant/sagapi-assets/refs/heads/assets/assets/ui/brandimage';
// TODO: add brand logo to the skins viewer

// Voice Assets from sagapi-audio repo
const String kVoiceRepo = 'https://github.com/elbriant/sagapi-audio/raw/refs/heads/audio/audio';
