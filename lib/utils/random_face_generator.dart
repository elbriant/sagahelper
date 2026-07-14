import 'dart:math';

class RandomFaceGenerator {
  static Random random = Random();

  static const List<String> surpriseFaces = ['（；￣д￣）', '(゜ ロ゜)', '(°~°) !!', 'Σ(ﾟ口ﾟ;)//'];
  static const List<String> sadFaces = ['(╥﹏╥)', '(◡﹏◡)', '(X╭╮X)', '(_ _|||)'];
  static const List<String> happyFaces = ['≧◡≦', '(✿◠‿◠)', '(^ｰ^)', '~ヾ(＾∇＾)'];

  static String surpriseFace() {
    return surpriseFaces[random.nextInt(surpriseFaces.length)];
  }

  static String sadFace() {
    return sadFaces[random.nextInt(sadFaces.length)];
  }

  static String happyFace() {
    return happyFaces[random.nextInt(happyFaces.length)];
  }

  static String anyFace() {
    final allFaces = [...surpriseFaces, ...sadFaces, ...happyFaces];

    return allFaces[random.nextInt(allFaces.length)];
  }
}
