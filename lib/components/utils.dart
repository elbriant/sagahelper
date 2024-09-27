extension StringExtension on String {
    String capitalize() {
      // ignore: unnecessary_this
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    }
}
