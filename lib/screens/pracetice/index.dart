import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_app/screens/pracetice/hear.dart';
import 'package:grammar_app/screens/pracetice/grammar.dart';
import 'package:grammar_app/screens/pracetice/vocabulary.dart';

class PraceticePage extends StatefulWidget {
  @override
  _PraceticePage createState() => _PraceticePage();
}

class _PraceticePage extends State<PraceticePage> {
  DateTime currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      EasyLoading.showToast('Bấm lần nữa để thoát ứng dụng');
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backwardsCompatibility: false,
          title: Text("Practice",
              style: GoogleFonts.laila(
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                  color: Colors.green)),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
        ),
        body: WillPopScope(
            onWillPop: onWillPop,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.17,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HearPage()),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage("assets/images/hearing.jpg"),
                                fit: BoxFit.cover,
                              ),
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
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                    child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Hear",
                                    style: GoogleFonts.laila(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.17,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WordFind()),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              image: DecorationImage(
                                image:
                                    AssetImage("assets/images/vocabulary.jpg"),
                                fit: BoxFit.cover,
                              ),
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
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                    child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Vocabulary Quizz",
                                    style: GoogleFonts.laila(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.17,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GrammarPage()),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage("assets/images/grammar.jpg"),
                                fit: BoxFit.cover,
                              ),
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
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                    child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Grammar Quizz",
                                    style: GoogleFonts.laila(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            )));
  }
}
