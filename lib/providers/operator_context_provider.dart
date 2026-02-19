import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagahelper/models/operator_context.dart';

typedef UpdateCallback = OperatorContext Function(OperatorContext current);

final operatorContextProvider =
    NotifierProvider.autoDispose<OperatorContextNotifier, OperatorContext>(
  OperatorContextNotifier.new,
);

// TODO: may create a future provider based on op info to get color Theme original
// based on image

class OperatorContextNotifier extends Notifier<OperatorContext> {
  @override
  OperatorContext build() {
    throw UnimplementedError('Must override and give entity info');
  }

  /// generic update meant to use update.copyWith(...)
  void update(UpdateCallback update) {
    state = update.call(state);
  }

  void setElite(int value, double maxLevel) {
    state = state.copyWith(
      elite: value,
      maxLevel: maxLevel,
      level: state.level.clamp(1.0, maxLevel),
    );
  }

  void setModAttrBuffs(Map<String, double> value) {
    state = state.copyWith(
      modAttrBuffs: value,
    );
  }
}
