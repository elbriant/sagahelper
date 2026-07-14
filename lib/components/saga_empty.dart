import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sagahelper/core/asset_service.dart';
import 'package:sagahelper/utils/random_face_generator.dart';

class SagaEmpty extends StatelessWidget {
  const SagaEmpty({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final sagaGifs = AssetService.assetSet
        .where(
          (element) => element.contains('gif/saga_'),
        )
        .toList();
    final rng = Random();

    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              child: SizedBox(
                height: 220,
                child: DrawerHeader(
                  child: Image.asset(
                    sagaGifs[rng.nextInt(sagaGifs.length)],
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            TextSpan(
              text: '\n${RandomFaceGenerator.anyFace()}',
              style: const TextStyle(fontSize: 32),
            ),
            if (message?.isNotEmpty ?? false)
              TextSpan(
                text: '\n $message',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
          ],
        ),
        style: TextStyle(
          fontSize: 40,
          color: Theme.of(context).colorScheme.outline,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
