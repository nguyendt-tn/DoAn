import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:grammar_app/models/gramar_quizz.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class GrammarPage extends StatefulWidget {
  @override
  _GrammarPage createState() => _GrammarPage();
}

class _GrammarPage extends State<GrammarPage> {
  List<Options> options = new List<Options>();
  List<GrammarModel> grammarQuizz = new List<GrammarModel>();
  List<String> _listwords = [];

  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache(fixedPlayer: AudioPlayer());

  Future<List<String>> _loadSuggest(String name) async {
    List<String> _listwords = [];
    await rootBundle.loadString('assets/questions/$name.txt').then((q) {
      for (String i in LineSplitter().convert(q)) {
        _listwords.add(i.trim());
      }
    });
    return _listwords;
  }

  void _setup() async {
    Random rnd = new Random();
    int range = 0 + rnd.nextInt(48 - 0);
    List<String> _listwords = await _loadSuggest("$range");
    setState(() {
      this._listwords = _listwords;
    });
    List<String> _listOptions = _listwords.sublist(1, 5);
    int correctAns = _listOptions.indexOf(_listwords[5]);
    options
        .add(new Options(0, false, false, correctAns, null, _listOptions[0]));
    options
        .add(new Options(1, false, false, correctAns, null, _listOptions[1]));
    options
        .add(new Options(2, false, false, correctAns, null, _listOptions[2]));
    options
        .add(new Options(3, false, false, correctAns, null, _listOptions[3]));
    grammarQuizz.add(
        new GrammarModel(_listwords[0], options, correctAns, _listwords[6]));
  }

  @override
  void initState() {
    super.initState();
    _setup();
  }

  int _index = 1;
  int _correctAns = 0;
  bool _isAnswered = false;
  int _selectedAns;

  @override
  Widget build(BuildContext context) {
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
                    value: _index / 10, // percent filled
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
              '$_index/10',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        )),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.025,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              height: MediaQuery.of(context).size.height * 0.14,
              child: Container(
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
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
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: HtmlWidget(
                      "<span style='font-size:20px;font-weight:bold;'>" +
                          grammarQuizz[0].question +
                          "</span>"),
                ),
                // child: Text(grammarQuizz[0].question,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.025,
            ),
            SizedBox(
                height: 20,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Chọn câu trả lời phù hợp",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.025,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width - 20,
              child: Container(
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
                child: Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        if (!_isAnswered) {
                          setState(() {
                            options.forEach(
                                (element) => element.isSelected = false);
                            options[0].isSelected = true;
                            _selectedAns = 0;
                          });
                        }
                      },
                      child: RadioItem(options[0]),
                    ),
                    InkWell(
                      onTap: () {
                        if (!_isAnswered) {
                          setState(() {
                            options.forEach(
                                (element) => element.isSelected = false);
                            options[1].isSelected = true;
                            _selectedAns = 1;
                          });
                        }
                      },
                      child: RadioItem(options[1]),
                    ),
                    InkWell(
                      onTap: () {
                        if (!_isAnswered) {
                          setState(() {
                            options.forEach(
                                (element) => element.isSelected = false);
                            options[2].isSelected = true;
                            _selectedAns = 2;
                          });
                        }
                      },
                      child: RadioItem(options[2]),
                    ),
                    InkWell(
                      onTap: () {
                        if (!_isAnswered) {
                          setState(() {
                            options.forEach(
                                (element) => element.isSelected = false);
                            options[3].isSelected = true;
                            _selectedAns = 3;
                          });
                        }
                      },
                      child: RadioItem(options[3]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.025,
            ),
            Expanded(
              child: _isAnswered
                  ? Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
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
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: HtmlWidget("<span style='font-size:18px;'>" +
                            grammarQuizz[0].explain +
                            "</span>"),
                      ))
                  : Offstage(
                      offstage: true,
                    ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 20,
                child: _index == 10
                    ? (_isAnswered
                        ? RaisedButton(
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                                    .circular(
                                                                        20),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey)),
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
                                                              "$_correctAns",
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
                                                                    .circular(
                                                                        20),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey)),
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
                                                              "${10 - _correctAns}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
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
                                                            Radius.circular(
                                                                100)),
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFF00FFED),
                                                          Color(0xFF00B8BA)
                                                        ],
                                                        begin: Alignment
                                                            .centerLeft,
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
                                                      Navigator.of(context)
                                                          .pop();
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
                            },
                          )
                        : RaisedButton(
                            child: Text(
                              "KIỂM TRA",
                              style: GoogleFonts.quicksand(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            color: Colors.grey[400],
                            onPressed: () {
                              setState(() {
                                if (grammarQuizz[0].correctAns ==
                                    _selectedAns) {
                                  _correctAns++;
                                  audioCache.play('audio/correct_answer.mp3');
                                } else {
                                  audioCache.play('audio/incorrect_answer.mp3');
                                }
                                options[_selectedAns].selectedAns =
                                    _selectedAns;
                                options[_selectedAns].isAnswered = true;
                                options[grammarQuizz[0].correctAns].isSelected =
                                    true;
                                options[grammarQuizz[0].correctAns].isAnswered =
                                    true;
                                _isAnswered = true;
                              });
                            },
                          ))
                    : _isAnswered
                        ? RaisedButton(
                            child: Text(
                              "KẾ TIẾP",
                              style: GoogleFonts.quicksand(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            color: Color(0xFFFF9800),
                            onPressed: () async {
                              Random rnd = new Random();
                              int range = 0 + rnd.nextInt(48 - 0);
                              List<String> _listwords =
                                  await _loadSuggest("$range");
                              setState(() {
                                _isAnswered = false;
                                _index++;
                                this._listwords = _listwords;
                                List<String> _listOptions =
                                    _listwords.sublist(1, 5);
                                int correctAns =
                                    _listOptions.indexOf(_listwords[5]);
                                options[0] = new Options(0, false, false,
                                    correctAns, null, _listOptions[0]);
                                options[1] = new Options(1, false, false,
                                    correctAns, null, _listOptions[1]);
                                options[2] = new Options(2, false, false,
                                    correctAns, null, _listOptions[2]);
                                options[3] = new Options(3, false, false,
                                    correctAns, null, _listOptions[3]);
                                grammarQuizz[0] = new GrammarModel(
                                    _listwords[0],
                                    options,
                                    correctAns,
                                    _listwords[6]);
                                _selectedAns = null;
                              });
                            },
                          )
                        : RaisedButton(
                            child: Text(
                              "KIỂM TRA",
                              style: GoogleFonts.quicksand(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            color: Colors.grey[400],
                            onPressed: () {
                              setState(() {
                                if (grammarQuizz[0].correctAns ==
                                    _selectedAns) {
                                  _correctAns++;
                                  audioCache.play('audio/correct_answer.mp3');
                                } else {
                                  audioCache.play('audio/incorrect_answer.mp3');
                                }
                                options[_selectedAns].selectedAns =
                                    _selectedAns;
                                options[_selectedAns].isAnswered = true;
                                options[grammarQuizz[0].correctAns].isSelected =
                                    true;
                                options[grammarQuizz[0].correctAns].isAnswered =
                                    true;
                                _isAnswered = true;
                              });
                            },
                          ))
          ],
        ),
      ),
    );
  }
}

class RadioItem extends StatelessWidget {
  final kGreenColor = Color(0xFF6AC259);
  final kRedColor = Color(0xFFE92E30);
  final kOrangeColor = Color(0xFFFF9800);
  Color getTheRightColor() {
    if (_item.isSelected) {
      if (_item.isAnswered) {
        if (_item.selectedAns == _item.correctAns &&
            _item.selectedAns == _item.index) {
          return kGreenColor;
        } else if (_item.correctAns == _item.index) {
          return kGreenColor;
        } else {
          return kRedColor;
        }
      }
      return kOrangeColor;
    } else {
      return Colors.white;
    }
  }

  IconData getTheRightIcon() {
    return getTheRightColor() == kRedColor ? Icons.close : Icons.done;
  }

  final Options _item;
  RadioItem(this._item);
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: MediaQuery.of(context).size.height * 0.35 / 4,
      padding: EdgeInsets.all(10),
      decoration: new BoxDecoration(
        color: getTheRightColor().withOpacity(0.2),
        border: new Border.all(width: 1.0, color: getTheRightColor()),
        borderRadius: const BorderRadius.all(const Radius.circular(5.0)),
      ),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            height: 26,
            width: 26,
            decoration: BoxDecoration(
              color: _item.isAnswered ? Colors.transparent : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: _item.isAnswered
                  ? null
                  : Border.all(
                      color: Colors.grey,
                    ),
            ),
            child: _item.isAnswered
                ? Icon(
                    getTheRightIcon(),
                    color: getTheRightColor(),
                  )
                : null,
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0),
            child: Text(
              _item.text,
              style: TextStyle(
                  color: _item.isAnswered ? getTheRightColor() : Colors.black),
            ),
          )
        ],
      ),
    );
  }
}
