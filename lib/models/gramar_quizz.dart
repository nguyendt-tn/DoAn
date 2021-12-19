class GrammarModel {
  String question;
  List<Options> options;
  int correctAns;
  String explain;
  GrammarModel(this.question, this.options, this.correctAns, this.explain);
}

class Options {
  int index;
  bool isSelected;
  bool isAnswered;
  int selectedAns;
  int correctAns;
  final String text;
  Options(this.index, this.isAnswered, this.isSelected, this.correctAns,
      this.selectedAns, this.text);
}