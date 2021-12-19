
import 'package:audioplayers/audioplayers.dart';

class WordFindQues {
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache(fixedPlayer: AudioPlayer());

  String question;
  String answer;
  bool isDone = false;
  bool isFull = false;
  List<WordFindChar> puzzles = new List<WordFindChar>();
  List<String> arrayBtns = new List<String>();

  WordFindQues({
    this.question,
    this.answer,
    this.arrayBtns,
  });

  void setWordFindChar(List<WordFindChar> puzzles) => this.puzzles = puzzles;

  void setIsDone() => this.isDone = true;

  bool fieldCompleteCorrect() {
    // lets declare class WordFindChar 1st
    // check all field already got value
    // fix color red when value not full but show red color
    bool complete =
        this.puzzles.where((puzzle) => puzzle.currentValue == null).length == 0;

    if (!complete) {
      // no complete yet
      this.isFull = false;
      return complete;
    }

    this.isFull = true;
    // if already complete, check correct or not

    String answeredString =
        this.puzzles.map((puzzle) => puzzle.currentValue).join("");
    if (answeredString == this.answer) {
      audioCache.play('audio/correct_answer.mp3');
    } else {
      audioCache.play('audio/incorrect_answer.mp3');
    }
    // if same string, answer is correct..yeay
    return answeredString == this.answer;
  }

  // more prefer name.. haha
  WordFindQues clone() {
    return new WordFindQues(
      answer: this.answer,
      question: this.question,
    );
  }

  // lets generate sample question
}

// done
class WordFindChar {
  String currentValue;
  int currentIndex;
  String correctValue;
  bool hintShow;

  WordFindChar({
    this.hintShow = false,
    this.correctValue,
    this.currentIndex,
    this.currentValue,
  });

  getCurrentValue() {
    if (this.correctValue != null)
      return this.currentValue;
    else if (this.hintShow) return this.correctValue;
  }

  void clearValue() {
    this.currentIndex = null;
    this.currentValue = null;
  }
}