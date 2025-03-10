import 'package:sagahelper/utils/extensions.dart';

Map<String, List<String>> customNames = {
  'Pozëmka': ['pozemka'],
  'Rosa': ['poca'],
  'Ling': ['blue woman'],
  "Ch'en": ['chen', 'blue woman'],
  "Ch'en the Holungday": ['chen', 'blue woman'],
  'Młynar': ['mlynar', 'milnar'],
  "Wiš'adel": ['wisadel', 'walter'],
};

class Operator {
  final Map<String, dynamic> operatorDict;
  final String id;
  final String name;
  final String? displayNumber;
  final String? description;
  final String? nationId;
  final String? groupId;
  final String? teamId;
  final String position;
  final List<dynamic> tagList;
  final int rarity;
  final String profession;
  final String subProfessionId;
  final String itemUsage;
  final String itemDesc;
  final List<String> names;
  final Map<String, dynamic> loreInfo;
  final Map<String, dynamic> voiceLangDict;
  final List<Map<String, dynamic>> charWordsList;
  final List<Map<String, dynamic>> skinsList;
  final Map<String, dynamic>? trait;
  final List<dynamic> phases;
  final List<dynamic> skills;
  final List<dynamic> talents;
  final List<dynamic> potentials;
  final List<dynamic> favorKeyframes;
  final List<dynamic> skillLvlMats;
  final Map<String, dynamic> baseSkills;
  final List<String>? modules;
  final bool opPatched;
  final String? altkey;

  Operator({
    required this.operatorDict,
    required this.id,
    required this.name,
    required this.rarity,
    required this.displayNumber,
    required this.description,
    required this.nationId,
    required this.groupId,
    required this.teamId,
    required this.position,
    required this.profession,
    required this.subProfessionId,
    required this.tagList,
    required this.itemUsage,
    required this.itemDesc,
    required this.names,
    required this.loreInfo,
    required this.voiceLangDict,
    required this.charWordsList,
    required this.skinsList,
    required this.trait,
    required this.phases,
    required this.talents,
    required this.skills,
    required this.potentials,
    required this.favorKeyframes,
    required this.skillLvlMats,
    required this.baseSkills,
    required this.modules,
    required this.opPatched,
    required this.altkey,
  });

  static String professionTranslate(String prof) => switch (prof) {
        'pioneer' => 'Vanguard',
        'special' => 'Specialist',
        'support' => 'Supporter',
        'tank' => 'Defender',
        'warrior' => 'Guard',
        String() => prof.capitalize(),
      };

  String get professionString => professionTranslate(profession.toLowerCase());

  static String subProfessionTranslate(String subprof) => switch (subprof) {
        'corecaster' => 'Core',
        'splashcaster' => 'Splash',
        'blastcaster' => 'Blast',
        'funnel' => 'Mech-Accord',
        'primcaster' => 'Primal',
        'unyield' => 'Juggernaut',
        'artsprotector' => 'Arts Protector',
        'shotprotector' => 'Sentry Protector',
        'fearless' => 'Dreadnought',
        'artsfghter' => 'Arts Fighter',
        'sword' => 'Swordmaster',
        'musha' => 'Soloblade',
        'librator' => 'Liberator',
        'physician' => 'Medic',
        'ringhealer' => 'Multi-Target',
        'healer' => 'Therapist',
        'wandermedic' => 'Wandering',
        'incantationmedic' => 'Incantation',
        'chainhealer' => 'Chain',
        'fastshot' => 'Marksman',
        'aoesniper' => 'Artilleryman',
        'longrange' => 'Deadeye',
        'closerange' => 'Heavyshooter',
        'reaperrange' => 'Spreadshooter',
        'siegesniper' => 'Besieger',
        'bombarder' => 'Flinger',
        'pusher' => 'Push Stroker',
        'stalker' => 'Ambusher',
        'traper' => 'Trapmaster',
        'slower' => 'Dencel Binder',
        'underminer' => 'Hexer',
        'blessing' => 'Abjurer',
        'craftsman' => 'Artificer',
        'bearer' => 'Standard Bearer',
        'hammer' => 'Earthshaker',
        String() => subprof.capitalize()
      };

  String get subProfessionString => subProfessionTranslate(subProfessionId.toLowerCase());

  static String statTranslate(String stat) => switch (stat) {
        "maxHp" => 'HP',
        "max_hp" => 'HP',
        "atk" => 'ATK',
        "def" => 'DEF',
        "magicResistance" => 'RES',
        "magic_resistance" => 'RES',
        "cost" => 'DPCost',
        "blockCnt" => 'Block',
        "block_cnt" => 'Block',
        "attackSpeed" => 'ASPD%',
        "attack_speed" => 'ASPD%',
        "baseAttackTime" => 'ASPD',
        "base_attack_time" => 'ASPD',
        "respawnTime" => 'Redeploy',
        "respawn_time" => 'Redeploy',
        "hpRecoveryPerSec" => 'HP/S',
        "spRecoveryPerSec" => 'SP/S',
        "tauntLevel" => 'Aggro',
        "taunt_level" => 'Aggro',
        "massLevel" => 'Weight',
        "stunImmune" => '',
        // was lazy to add all
        String() => stat.capitalize()
      };

  List<String>? get factionIds {
    List<String> list = [teamId, groupId, nationId].nonNulls.toList();
    return list.isNotEmpty ? list : null;
  }

  factory Operator.fromJson(
    String key,
    Map<String, dynamic> dict,
    Map<String, dynamic> loreDict,
    Map<String, dynamic> voiceDict,
    Map<String, dynamic> charSkins,
    Map<String, dynamic> baseSkills,
    Map<String, dynamic> modTable,
    Map<String, dynamic> patchChars,
  ) {
    // have to do this just bc amiya
    bool patched = false;
    // ignore: no_leading_underscores_for_local_identifiers
    String? _altkey;
    for (MapEntry<String, dynamic> patch in (patchChars["infos"] as Map<String, dynamic>).entries) {
      if ((patch.value["tmplIds"] as List).contains(key)) {
        _altkey = patch.value["default"];
        patched = true;
        break;
      }
    }

    //custom names
    String name = dict['name'];
    var names = <String>[name];

    if (customNames.containsKey(name)) {
      names.addAll(customNames[name]!);
    }

    List<Map<String, dynamic>> getVoices(
      Map<String, dynamic> charWords,
      String opKey,
    ) {
      List<Map<String, dynamic>> result = [];

      charWords.forEach((key, value) {
        if (key.startsWith(opKey)) {
          result.add(value);
        }
      });
      return result;
    }

    List<Map<String, dynamic>> getSkins(
      Map<String, dynamic> charskins,
      String opKey,
    ) {
      List<Map<String, dynamic>> result = [];
      charskins.forEach((key, value) {
        if (key.startsWith(opKey)) {
          result.add(value);
        }
      });
      return result;
    }

    return Operator(
      operatorDict: dict,
      id: key,
      altkey: _altkey,
      name: dict['name'],
      rarity: int.parse((dict['rarity'] as String).replaceAll('TIER_', '')),
      description: dict['description'],
      displayNumber: dict['displayNumber'],
      groupId: dict['groupId'],
      nationId: dict['nationId'],
      teamId: dict['teamId'],
      position: dict['position'],
      profession: dict['profession'],
      subProfessionId: dict['subProfessionId'],
      tagList: dict['tagList'],
      itemUsage: dict['itemUsage'],
      itemDesc: dict['itemDesc'],
      names: names,
      loreInfo: loreDict[key] ?? ((patched) ? loreDict[_altkey] : {}),
      voiceLangDict: voiceDict['voiceLangDict'][key] ??
          ((patched) ? voiceDict['voiceLangDict'][_altkey] : null),
      charWordsList: getVoices(voiceDict['charWords'], key),
      skinsList: getSkins(charSkins, key),
      trait: dict['trait'],
      phases: dict['phases'],
      skills: dict['skills'],
      talents: dict['talents'],
      potentials: dict['potentialRanks'],
      favorKeyframes: dict['favorKeyFrames'],
      skillLvlMats: dict['allSkillLvlup'],
      baseSkills: baseSkills[key] ?? ((patched) ? baseSkills[_altkey] : null),
      modules: (modTable[key] as List<dynamic>?)?.map((e) => e as String).toList(),
      opPatched: patched,
    );
  }
}
