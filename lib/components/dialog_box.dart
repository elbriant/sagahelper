import 'package:sagahelper/components/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:styled_text/widgets/styled_text.dart';

class DialogBox extends StatelessWidget {
  final String? title;
  final String body;
  final bool combineWithTheme;
  const DialogBox({super.key, this.title, required this.body, this.combineWithTheme = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10.0, left: 4.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0x80000000),
                blurStyle: BlurStyle.outer,
                blurRadius: 12.0
              )
            ],
            color: combineWithTheme ? Color.lerp(Color(0xa6000000), Theme.of(context).colorScheme.primary, 0.35) : Color(0xa6000000)
          ),
          child: StyledText(
            text: body,
            style: TextStyle(color: Colors.white, fontFamily: 'Noto Sans', fontWeight: FontWeight.w700),
            tags: tagsAsHtml,
          )
        ),
        title != null ? Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF9e9e9e),
              boxShadow: [
                BoxShadow(
                color: const Color(0x80000000),
                offset: Offset(0, 3),
                blurRadius: 6.0
              )
              ],
            ),
            child: Text(title!.padRight(36), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), ),
          )
        ) : SizedBox()
      ],
    );
  }
}

class InkWellDialogBox extends StatelessWidget {
  final String? title;
  final String body;
  final bool combineWithTheme;
  final Function()? inkwellFun;
  const InkWellDialogBox({super.key, this.title, required this.body, this.inkwellFun, this.combineWithTheme = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10.0, left: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              width: double.maxFinite,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x80000000),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 12.0
                  )
                ],
                color: combineWithTheme ? Color.lerp(Color(0xa6000000), Theme.of(context).colorScheme.primary, 0.65) : Color(0xa6000000)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StyledText(
                      text: body,
                      style: TextStyle(color: Colors.white, fontFamily: 'Noto Sans', fontWeight: FontWeight.w700),
                      tags: tagsAsHtml,
                    ),
                  ),
                  Center(
                      child: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.secondaryContainer, size: 32)
                    ),
                ],
              )
            ),
            title != null ? Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF9e9e9e),
                  boxShadow: [
                    BoxShadow(
                    color: const Color(0x80000000),
                    offset: Offset(0, 3),
                    blurRadius: 6.0
                  )
                  ],
                ),
                child: Text(title!, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), ),
              )
            ) : SizedBox()
            
          ],
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: inkwellFun,
            ),
          ),
        )
      ],
    );
  }
}

class AudioDialogBox extends StatefulWidget {
  final String? title;
  final String body;
  final bool combineWithTheme;
  const AudioDialogBox({super.key, this.title, required this.body, this.combineWithTheme = true});

  @override
  State<AudioDialogBox> createState() => _AudioDialogBoxState();
}

class _AudioDialogBoxState extends State<AudioDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10.0, left: 4.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0x80000000),
                blurStyle: BlurStyle.outer,
                blurRadius: 12.0
              )
            ],
            color: widget.combineWithTheme ? Color.lerp(Color(0xa6000000), Theme.of(context).colorScheme.primary, 0.35) : Color(0xa6000000)
          ),
          child: StyledText(
            text: widget.body,
            style: TextStyle(color: Colors.white, fontFamily: 'Noto Sans', fontWeight: FontWeight.w700),
            tags: tagsAsHtml,
          )
        ),
        widget.title != null ? Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF9e9e9e),
              boxShadow: [
                BoxShadow(
                color: const Color(0x80000000),
                offset: Offset(0, 3),
                blurRadius: 6.0
              )
              ],
            ),
            child: Text(widget.title!.padRight(36), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ) : SizedBox()
      ],
    );
  }
}