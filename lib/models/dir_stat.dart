import 'dart:io';
import 'package:filesize/filesize.dart';

class DirStat {
  final int numberOfFiles;
  final int totalSize;

  DirStat({required this.numberOfFiles, required this.totalSize});
  String get totalSizeString => filesize(totalSize);

  static Future<DirStat> getDirStat(String dirPath) async {
    var dir = Directory(dirPath);
    bool exists = await dir.exists();
    if (!exists) {
      return DirStat(numberOfFiles: 0, totalSize: 0);
    }

    int numberOfFiles = 0;
    int totalSize = 0;
    await dir.list(recursive: true, followLinks: false).forEach((FileSystemEntity entity) async {
      if (entity is File) {
        numberOfFiles++;
        totalSize += await entity.length();
      }
    });

    return DirStat(numberOfFiles: numberOfFiles, totalSize: totalSize);
  }
}
