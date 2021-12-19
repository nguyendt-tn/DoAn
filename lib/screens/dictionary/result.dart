import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:grammar_app/models/dictionary.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DictionarResult extends StatefulWidget {
  final Dictionary result;
  DictionarResult({this.result});
  @override
  _DictionarResult createState() => _DictionarResult();
}

class _DictionarResult extends State<DictionarResult> {
  int _numTab = 0;

  bool isConnect = false;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> networkSubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    networkSubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

      print(widget.result.pronunciation_uk);
      print(widget.result.pronunciation_us);
    if (widget.result.form != "") _numTab++;
    if (widget.result.definition != "") _numTab++;
    if (widget.result.similar != "") _numTab++;
    if (widget.result.speciality != "") _numTab++;
    if(widget.result.pronunciation_uk!="" || widget.result.pronunciation_us != ""){
      _numTab++;
    }
    _numTab += 1;
  }

  @override
  void dispose() {
    networkSubscription.cancel();
    super.dispose();
  }

  final Set<Factory> gestureRecognizers =
      [Factory(() => VerticalDragGestureRecognizer())].toSet();

  WebViewController _myController;

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _numTab,
      child: Scaffold(
        appBar: AppBar(
          backwardsCompatibility: false,
          title: Text(
            widget.result.word,
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold, fontSize: 28),
          ),
          flexibleSpace:
              Container(decoration: BoxDecoration(color: Color(0xFF63F2D8))),
          bottom: TabBar(
            isScrollable: true,
            // unselectedLabelColor: Colors.black,
            indicatorColor: Color(0xffF15C22),
            tabs: [
              if (widget.result.definition != "")
                Tab(
                  text: "ENG- VIE",
                ),
              if (widget.result.form != "")
                Tab(
                  text: "GRAMMAR",
                ),
              if (widget.result.similar != "")
                Tab(
                  text: "SYNONYMS",
                ),
              if (widget.result.speciality != "")
                Tab(
                  text: "SPECIALIZED",
                ),
              if(widget.result.pronunciation_uk!="" || widget.result.pronunciation_us != "") Tab(
                text: "OXFORD",
              ),
              Tab(
                text: "HÌNH ẢNH",
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            if (widget.result.definition != "")
              PageDefinition(
                result: widget.result,
              ),
            if (widget.result.form != "")
              PageForm(
                result: widget.result,
              ),
            if (widget.result.similar != "")
              PageSimilar(
                result: widget.result,
              ),
            if (widget.result.speciality != "")
              PageSpeciality(
                result: widget.result,
              ),
            if(widget.result.pronunciation_uk!="" || widget.result.pronunciation_us != "") Stack(
              children: <Widget>[
                // ignore: unrelated_type_equality_checksR
                isConnect == true
                    ? WebView(
                        initialUrl:
                            'http://www.oxfordlearnersdictionaries.com/search/english/direct/?q=${widget.result.word}',
                        javascriptMode: JavascriptMode.unrestricted,
                        gestureRecognizers: gestureRecognizers,
                        onWebViewCreated: (WebViewController controller) {
                          _myController = controller;
                        },
                        onPageFinished: (url) async {
                          await _myController.evaluateJavascript(
                              'document.querySelector("#onetrust-accept-btn-handler").click()');
                        },
                      )
                    : Center(
                        child: Text(
                            "Vui lòng kết nối internet để sử dụng chức năng này."),
                      ),
              ],
            ),
            Stack(
              children: <Widget>[
                // ignore: unrelated_type_equality_checks
                isConnect == true
                    ? WebView(
                        initialUrl:
                            'https://www.google.com/search?q=${widget.result.word}&tbm=isch',
                        // javascriptMode: JavascriptMode.unrestricted,
                        gestureRecognizers: gestureRecognizers,
                      )
                    : Center(
                        child: Text(
                            "Vui lòng kết nối internet để sử dụng chức năng này."),
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      setState(() {
        isConnect = false;
      });
    } else {
      setState(() {
        isConnect = true;
      });
    }
  }

}

class PageDefinition extends StatefulWidget {
  final Dictionary result;
  PageDefinition({this.result});

  @override
  _PageDefinitionState createState() => _PageDefinitionState();
}

class _PageDefinitionState extends State<PageDefinition> {
  bool _isListenUK = false;
  bool _isListenUS = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.80),
        child: Column(
          children: <Widget>[
            widget.result.pronunciation_uk != ""
                ? Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xFF63F2D8),
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isListenUK
                                ? Icons.volume_up
                                : Icons.volume_up_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () async {
                            setState(() {
                              _isListenUK = true;
                            });
                            FlutterTts flutterTts = new FlutterTts();
                            await flutterTts.setLanguage('en-GB');
                            await flutterTts.setVoice({
                              "name": "en-gb-x-gbg-network",
                              "locale": "en-GB"
                            });

                            await flutterTts.speak(widget.result.word);
                            await flutterTts.setCompletionHandler(() {
                              setState(() {
                                _isListenUK = false;
                              });
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 40,
                        margin: EdgeInsets.only(left: 8, top: 5),
                        alignment: Alignment.center,
                        child: Text(
                          "UK",
                          style: GoogleFonts.quicksand(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  )
                : Container(),
            SizedBox(
              height: 8,
            ),
            widget.result.pronunciation_us != ""
                ? Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xFF63F2D8),
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isListenUS
                                ? Icons.volume_up
                                : Icons.volume_up_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () async {
                            setState(() {
                              _isListenUS = true;
                            });
                            FlutterTts flutterTts = new FlutterTts();
                            await flutterTts.setLanguage("en-US");
                            await flutterTts.setVoice({
                              "name": "en-us-x-tpf-network",
                              "locale": "en-US"
                            });
                            await flutterTts.speak(widget.result.word);
                            await flutterTts.setCompletionHandler(() {
                              setState(() {
                                _isListenUS = false;
                              });
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 40,
                        margin: EdgeInsets.only(left: 8, top: 5),
                        alignment: Alignment.center,
                        child: Text(
                          "US",
                          style: GoogleFonts.quicksand(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                      child: Text(
                    widget.result.word,
                    style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold, fontSize: 25),
                  )),
                  SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      if (widget.result.pronunciation_uk != "")
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: HtmlWidget(
                              '<div style="padding-bottom:.5em;">' +
                                  widget.result.pronunciation_uk +
                                  "</div>"),
                        ),
                    ],
                  )),
                  SizedBox(
                    height: 10,
                  ),
                  HtmlWidget(widget.result.definition),
                  SizedBox(
                    height: 100,
                  ),
                ])),
      ),
    );
  }
}

class PageForm extends StatefulWidget {
  final Dictionary result;
  PageForm({this.result});

  @override
  _PageFormState createState() => _PageFormState();
}

class _PageFormState extends State<PageForm> {
  bool _isListenUK = false;
  bool _isListenUS = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05,
              left: MediaQuery.of(context).size.width * 0.80),
          child: Column(
            children: <Widget>[
              widget.result.pronunciation_uk != ""
                  ? Row(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Color(0xFF63F2D8),
                              borderRadius: BorderRadius.circular(30)),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _isListenUK
                                  ? Icons.volume_up
                                  : Icons.volume_up_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () async {
                              setState(() {
                                _isListenUK = true;
                              });
                              FlutterTts flutterTts = new FlutterTts();
                              await flutterTts.setLanguage('en-GB');
                              await flutterTts.setVoice({
                                "name": "en-gb-x-gbg-network",
                                "locale": "en-GB"
                              });

                              await flutterTts.speak(widget.result.word);
                              await flutterTts.setCompletionHandler(() {
                                setState(() {
                                  _isListenUK = false;
                                });
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 40,
                          margin: EdgeInsets.only(left: 8, top: 5),
                          alignment: Alignment.center,
                          child: Text(
                            "UK",
                            style: GoogleFonts.quicksand(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    )
                  : Container(),
              SizedBox(
                height: 8,
              ),
              widget.result.pronunciation_us != ""
                  ? Row(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Color(0xFF63F2D8),
                              borderRadius: BorderRadius.circular(30)),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _isListenUS
                                  ? Icons.volume_up
                                  : Icons.volume_up_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () async {
                              setState(() {
                                _isListenUS = true;
                              });
                              FlutterTts flutterTts = new FlutterTts();
                              await flutterTts.setLanguage("en-US");
                              await flutterTts.setVoice({
                                "name": "en-us-x-tpf-network",
                                "locale": "en-US"
                              });
                              await flutterTts.speak(widget.result.word);
                              await flutterTts.setCompletionHandler(() {
                                setState(() {
                                  _isListenUS = false;
                                });
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 40,
                          margin: EdgeInsets.only(left: 8, top: 5),
                          alignment: Alignment.center,
                          child: Text(
                            "US",
                            style: GoogleFonts.quicksand(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                    child: Text(
                  widget.result.word,
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold, fontSize: 25),
                )),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    if (widget.result.pronunciation_uk != "")
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: HtmlWidget('<div style="padding-bottom:.5em;">' +
                            widget.result.pronunciation_uk +
                            "</div>"),
                      ),
                  ],
                )),
                SizedBox(
                  height: 10,
                ),
                HtmlWidget(widget.result.form),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ));
  }
}

class PageSimilar extends StatefulWidget {
  final Dictionary result;
  PageSimilar({this.result});

  @override
  _PageSimilarState createState() => _PageSimilarState();
}

class _PageSimilarState extends State<PageSimilar> {
  bool _isListenUK = false;
  bool _isListenUS = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.80),
        child: Column(
          children: <Widget>[
            widget.result.pronunciation_uk != ""
                ? Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xFF63F2D8),
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isListenUK
                                ? Icons.volume_up
                                : Icons.volume_up_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () async {
                            setState(() {
                              _isListenUK = true;
                            });
                            FlutterTts flutterTts = new FlutterTts();
                            await flutterTts.setLanguage('en-GB');
                            await flutterTts.setVoice({
                              "name": "en-gb-x-gbg-network",
                              "locale": "en-GB"
                            });

                            await flutterTts.speak(widget.result.word);
                            await flutterTts.setCompletionHandler(() {
                              setState(() {
                                _isListenUK = false;
                              });
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 40,
                        margin: EdgeInsets.only(left: 8, top: 5),
                        alignment: Alignment.center,
                        child: Text(
                          "UK",
                          style: GoogleFonts.quicksand(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  )
                : Container(),
            SizedBox(
              height: 8,
            ),
            widget.result.pronunciation_us != ""
                ? Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xFF63F2D8),
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isListenUS
                                ? Icons.volume_up
                                : Icons.volume_up_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () async {
                            setState(() {
                              _isListenUS = true;
                            });
                            FlutterTts flutterTts = new FlutterTts();
                            await flutterTts.setLanguage("en-US");
                            await flutterTts.setVoice({
                              "name": "en-us-x-tpf-network",
                              "locale": "en-US"
                            });
                            await flutterTts.speak(widget.result.word);
                            await flutterTts.setCompletionHandler(() {
                              setState(() {
                                _isListenUS = false;
                              });
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 40,
                        margin: EdgeInsets.only(left: 8, top: 5),
                        alignment: Alignment.center,
                        child: Text(
                          "US",
                          style: GoogleFonts.quicksand(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                  child: Text(
                widget.result.word,
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold, fontSize: 25),
              )),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  if (widget.result.pronunciation_uk != "")
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: HtmlWidget('<div style="padding-bottom:.5em;">' +
                          widget.result.pronunciation_uk +
                          "</div>"),
                    ),
                ],
              )),
              SizedBox(
                height: 10,
              ),
              HtmlWidget(widget.result.similar),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageSpeciality extends StatefulWidget {
  final Dictionary result;
  PageSpeciality({this.result});

  @override
  _PageSpecialityState createState() => _PageSpecialityState();
}

class _PageSpecialityState extends State<PageSpeciality> {
  bool _isListenUK = false;
  bool _isListenUS = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.80),
        child: Column(
          children: <Widget>[
            widget.result.pronunciation_uk != ""
                ? Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xFF63F2D8),
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isListenUK
                                ? Icons.volume_up
                                : Icons.volume_up_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () async {
                            setState(() {
                              _isListenUK = true;
                            });
                            FlutterTts flutterTts = new FlutterTts();
                            await flutterTts.setLanguage('en-GB');
                            await flutterTts.setVoice({
                              "name": "en-gb-x-gbg-network",
                              "locale": "en-GB"
                            });

                            await flutterTts.speak(widget.result.word);
                            await flutterTts.setCompletionHandler(() {
                              setState(() {
                                _isListenUK = false;
                              });
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 40,
                        margin: EdgeInsets.only(left: 8, top: 5),
                        alignment: Alignment.center,
                        child: Text(
                          "UK",
                          style: GoogleFonts.quicksand(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  )
                : Container(),
            SizedBox(
              height: 8,
            ),
            widget.result.pronunciation_us != ""
                ? Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xFF63F2D8),
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isListenUS
                                ? Icons.volume_up
                                : Icons.volume_up_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () async {
                            setState(() {
                              _isListenUS = true;
                            });
                            FlutterTts flutterTts = new FlutterTts();
                            await flutterTts.setLanguage("en-US");
                            await flutterTts.setVoice({
                              "name": "en-us-x-tpf-network",
                              "locale": "en-US"
                            });
                            await flutterTts.speak(widget.result.word);
                            await flutterTts.setCompletionHandler(() {
                              setState(() {
                                _isListenUS = false;
                              });
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 40,
                        margin: EdgeInsets.only(left: 8, top: 5),
                        alignment: Alignment.center,
                        child: Text(
                          "US",
                          style: GoogleFonts.quicksand(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                  child: Text(
                widget.result.word,
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold, fontSize: 25),
              )),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  if (widget.result.pronunciation_uk != "")
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: HtmlWidget('<div style="padding-bottom:.5em;">' +
                          widget.result.pronunciation_uk +
                          "</div>"),
                    ),
                ],
              )),
              SizedBox(
                height: 10,
              ),
              HtmlWidget(widget.result.speciality),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
