import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:word_search/word_search.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:grammar_app/models/puzzle_quizz.dart';

class WordFind extends StatefulWidget {
  WordFind({Key key}) : super(key: key);

  @override
  _WordFindState createState() => _WordFindState();
}

class _WordFindState extends State<WordFind> {
  GlobalKey<_WordFindWidgetState> globalKey = GlobalKey();

  List<WordFindQues> listQuestions;
  // ignore: missing_return
  Future<List> function() async {
    // do something here
    List<WordFindQues> listQuestions = new List<WordFindQues>();
    Random rnd = new Random();
    int range = 1 + rnd.nextInt(2990 - 1);
    int start = range;
    int end = range + 10;
    for (var i = start; i < end; i++) {
      var content = await rootBundle.loadString('assets/vocabulary/$i.txt');
      var jsonRespone = json.decode(content);
      listQuestions.add(WordFindQues(
          question: jsonRespone["vi_type"] + " " + jsonRespone["vi_terms"],
          answer: jsonRespone['answer']));
    }
    return listQuestions;
  }

  void _setup() async {
    Random rnd = new Random();
    int count = 0;
    int range = 1 + rnd.nextInt(2990 - 1);
    int start = range;
    int end = range + 10;
    for (var i = start; i < end; i++) {
      count++;
      print(count);
      var content = await rootBundle.loadString('assets/vocabulary/$i.txt');
      var jsonRespone = json.decode(content);
      listQuestions.add(WordFindQues(
          question: jsonRespone["vi_type"] + " " + jsonRespone["vi_terms"],
          answer: jsonRespone['answer']));
    }
  }

  @override
  void initState() {
    super.initState();
    function().then((List value) {
      setState(() {
        listQuestions = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  child: WordFindWidget(
                    constraints.biggest,
                    listQuestions.map((ques) => ques.clone()).toList(),
                    key: globalKey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WordFindWidget extends StatefulWidget {
  Size size;
  List<WordFindQues> listQuestions;
  WordFindWidget(this.size, this.listQuestions, {Key key}) : super(key: key);

  @override
  _WordFindWidgetState createState() => _WordFindWidgetState();
}

class _WordFindWidgetState extends State<WordFindWidget> {
  Size size;
  List<WordFindQues> listQuestions;
  int indexQues = 0;
  int hintCount = 0;
  int correctAns = 0;

  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache(fixedPlayer: AudioPlayer());

  @override
  void initState() {
    super.initState();
    size = widget.size;
    listQuestions = widget.listQuestions;
    generatePuzzle();
  }

  @override
  Widget build(BuildContext context) {
    WordFindQues currentQues = listQuestions[indexQues];
    return Scaffold(
        appBar: AppBar(
          backwardsCompatibility: false,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          title: Container(
              child: Row(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 15,
                    child: LinearProgressIndicator(
                      value: (indexQues + 1) / 10,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      backgroundColor: Color(0xFFFFDAB8),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                '${indexQues + 1}/10',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          )),
        ),
        body: Container(
          width: double.maxFinite,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => generateHint(),
                      child: Icon(
                        Icons.support_outlined,
                        size: 30,
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => generatePuzzle(left: true),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 30,
                          ),
                        ),
                        InkWell(
                          onTap: () => generatePuzzle(next: true),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 30,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(child: Container()),
              SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                height: MediaQuery.of(context).size.height * 0.14,
                child: Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xffffffff),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Text(
                    currentQues.question,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                alignment: Alignment.center,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      children: currentQues.puzzles.map((puzzle) {
                        // later change color based condition
                        Color color;

                        if (currentQues.isDone)
                          color = Color(0xFF6AC259);
                        else if (puzzle.hintShow)
                          color = Colors.yellow[100];
                        else if (currentQues.isFull)
                          color = Color(0xFFE92E30);
                        else
                          color = Colors.white;

                        return InkWell(
                          onTap: () {
                            if (puzzle.hintShow || currentQues.isDone) return;

                            currentQues.isFull = false;
                            puzzle.clearValue();
                            setState(() {});
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(
                                      0, 1), // changes position of shadow
                                ),
                              ],
                            ),
                            width: constraints.biggest.width / 7 - 6,
                            height: constraints.biggest.width / 7 - 6,
                            margin: EdgeInsets.all(3),
                            child: Text(
                              "${puzzle.currentValue ?? ''}".toUpperCase(),
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Expanded(child: Container()),
              Container(
                alignment: Alignment.center,
                child: GridView.builder(
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    crossAxisCount: 6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 18, // later change
                  shrinkWrap: true,
                  padding: EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    bool statusBtn = currentQues.puzzles.indexWhere(
                            (puzzle) => puzzle.currentIndex == index) >=
                        0;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        Color color =
                            statusBtn ? Color(0xFFFF9800) : Colors.white;

                        return Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset:
                                    Offset(0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: FlatButton(
                            height: constraints.biggest.height,
                            child: Text(
                              "${currentQues.arrayBtns[index]}".toUpperCase(),
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              if (!statusBtn) setBtnClick(index);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Expanded(child: Container()),
              indexQues == listQuestions.length - 1 &&
                      listQuestions[listQuestions.length - 1].isDone
                  ? Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(),
                      child: RaisedButton(
                          color: Color(0xFF6AC259),
                          child: Text(
                            "XEM KẾT QUẢ",
                            style: GoogleFonts.quicksand(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                          onPressed: () {
                            audioCache.play('audio/end.mp3');
                            showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.0)), //this right here
                                    child: Container(
                                      height: 250,
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 50,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Kết quả",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 100,
                                            child: Container(
                                              width: 250,
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            "Đúng",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 19,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            "$correctAns",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 19,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 50,
                                                    ),
                                                    Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey)),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            "Sai",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 19,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            "${10 - correctAns}",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 19,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 100,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 40,
                                                width: 250,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(100)),
                                                  gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFF00FFED),
                                                        Color(0xFF00B8BA)
                                                      ],
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end: Alignment
                                                          .centerRight),
                                                ),
                                                child: FlatButton(
                                                  child: Text(
                                                    "OK",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        dialogContext);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          }),
                    )
                  : Container(
                      height: 50,
                    )
            ],
          ),
        ));
  }

  void generatePuzzle({
    List<WordFindQues> loop,
    bool next: false,
    bool left: false,
  }) {
    // lets finish up generate puzzle
    if (loop != null) {
      indexQues = 0;
      this.listQuestions = new List<WordFindQues>();
      this.listQuestions.addAll(loop);
    } else {
      if (next && indexQues < listQuestions.length - 1)
        indexQues++;
      else if (left && indexQues > 0)
        indexQues--;
      else if (indexQues >= listQuestions.length - 1) {
        return;
      }
      setState(() {});

      if (this.listQuestions[indexQues].isDone) {
        return;
      }
    }

    WordFindQues currentQues = listQuestions[indexQues];

    setState(() {});

    final List<String> wl = [currentQues.answer];

    final WSSettings ws = WSSettings(
      width: 18, // total random word row we want use
      height: 1,
      orientations: List.from([
        WSOrientation.horizontal,
      ]),
    );

    final WordSearch wordSearch = WordSearch();

    final WSNewPuzzle newPuzzle = wordSearch.newPuzzle(wl, ws);

    // check if got error generate random word
    if (newPuzzle.errors.isEmpty) {
      currentQues.arrayBtns = newPuzzle.puzzle.expand((list) => list).toList();
      currentQues.arrayBtns.shuffle(); // make shuffle so user not know answer
      bool isDone = currentQues.isDone;

      if (!isDone) {
        currentQues.puzzles = List.generate(wl[0].split("").length, (index) {
          return WordFindChar(
              correctValue: currentQues.answer.split("")[index]);
        });
      }
    }

    hintCount = 0; //number hint per ques we hit
    setState(() {});
  }

  generateHint() async {
    // let dclare hint
    WordFindQues currentQues = listQuestions[indexQues];

    List<WordFindChar> puzzleNoHints = currentQues.puzzles
        .where((puzzle) => !puzzle.hintShow && puzzle.currentIndex == null)
        .toList();

    if (puzzleNoHints.length > 0) {
      hintCount++;
      int indexHint = Random().nextInt(puzzleNoHints.length);
      int countTemp = 0;

      currentQues.puzzles = currentQues.puzzles.map((puzzle) {
        if (!puzzle.hintShow && puzzle.currentIndex == null) countTemp++;

        if (indexHint == countTemp - 1) {
          puzzle.hintShow = true;
          puzzle.currentValue = puzzle.correctValue;
          puzzle.currentIndex = currentQues.arrayBtns
              .indexWhere((btn) => btn == puzzle.correctValue);
        }

        return puzzle;
      }).toList();

      // check if complete

      if (currentQues.fieldCompleteCorrect()) {
        currentQues.isDone = true;
        correctAns++;
        audioCache.play('audio/correct_answer.mp3');
        setState(() {});
        await Future.delayed(Duration(seconds: 1));
        generatePuzzle(next: true);
      }
      setState(() {});
    }
  }

  Future<void> setBtnClick(int index) async {
    WordFindQues currentQues = listQuestions[indexQues];

    int currentIndexEmpty =
        currentQues.puzzles.indexWhere((puzzle) => puzzle.currentValue == null);

    if (currentIndexEmpty >= 0) {
      currentQues.puzzles[currentIndexEmpty].currentIndex = index;
      currentQues.puzzles[currentIndexEmpty].currentValue =
          currentQues.arrayBtns[index];

      if (currentQues.fieldCompleteCorrect()) {
        currentQues.isDone = true;
        setState(() {});

        await Future.delayed(Duration(seconds: 1));
        generatePuzzle(next: true);
      }
      setState(() {});
    }
  }
}
