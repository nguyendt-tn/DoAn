class Grammar {
  int index;
  int offset;
  String type;
  String shortMessage;
  String errorWord;
  String message;
  List<String> replace;
  Grammar(
      {this.index,
      this.offset,
      this.type,
      this.shortMessage,
      this.errorWord,
      this.message,
      this.replace});
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}