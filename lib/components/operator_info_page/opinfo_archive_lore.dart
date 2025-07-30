import 'package:flutter/material.dart';
import 'package:sagahelper/components/dialog_box.dart';
import 'package:sagahelper/core/global_data.dart';
import 'package:sagahelper/models/operator.dart';
import 'package:sagahelper/utils/extensions.dart';

class OpinfoArchiveLore extends StatelessWidget {
  const OpinfoArchiveLore(this.operator, {super.key});
  final Operator operator;

  void playOperatorRecord() {
    ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
        .showSnackBar(const SnackBar(content: Text('not implemented yet')));
  }

  @override
  Widget build(BuildContext context) {
    bool hasOperatorRecords = (operator.loreInfo['handbookAvgList'] as List).isNotEmpty;
    List storyTextList = (operator.loreInfo['storyTextAudio'] as List);
    List operatorRecords = (operator.loreInfo['handbookAvgList'] as List);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
          hasOperatorRecords ? storyTextList.length + operatorRecords.length : storyTextList.length,
          (index) {
        if (hasOperatorRecords && index >= storyTextList.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
            child: InkWellDialogBox(
              title:
                  'Operator Record: ${operatorRecords[index - storyTextList.length]['storySetName']}',
              body: ((operatorRecords[index - storyTextList.length]['avgList'] as List).first
                  as Map)['storyIntro'],
              inkwellFun: playOperatorRecord,
            ),
          );
        }
        if (operator.opPatched &&
            !(((storyTextList[index]['stories'] as List).first as Map)["patchIdList"] as List)
                .contains(operator.id)) {
          return null;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
          child: DialogBox(
            title: storyTextList[index]['storyTitle'],
            body: ((storyTextList[index]['stories'] as List).first as Map)['storyText'],
          ),
        );
      }).nullParser(),
    );
  }
}
