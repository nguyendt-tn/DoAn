import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_app/api/speech_api.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:grammar_app/models/dictionary.dart';
import 'package:grammar_app/screens/dictionary/result.dart';
import 'package:http/http.dart' as http;
import 'package:localstore/localstore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DictionaryPage extends StatefulWidget {
  @override
  _DictionaryPage createState() => _DictionaryPage();
}

class _DictionaryPage extends State<DictionaryPage> {
  List<String> _listwords = [];

  bool loading = true;
  bool isListening = false;
  bool isShow = false;

  final db = Localstore.instance;
  List<Dictionary> _items = new List<Dictionary>();

  String baseURL = "https://dictionary.nguyendt.dev";
  String token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9';

  FlutterTts flutterTts = FlutterTts();

  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache(fixedPlayer: AudioPlayer());

  final _suggestTextController = TextEditingController();

  Future<List<String>> _loadSuggest(String query) async {
    List<String> _listwords = [];
    await rootBundle.loadString('assets/words/english.txt').then((q) {
      for (String i in LineSplitter().convert(q)) {
        _listwords.add(i);
      }
    });

    _listwords.retainWhere((s) => s.contains(query) && s.startsWith(query));
    return _listwords;
  }

  _setup() async {
    var value = await db.collection('dictionaries').get();
    List<Dictionary> _list = new List<Dictionary>();
    setState(() {
      value?.entries
          ?.forEach((element) => _list.add(Dictionary.fromMap(element.value)));

      for (var i = 0; i < _list.length; i++) {
        _items.add(_list[_list.length - 1 - i]);
      }

      final Map<String, Dictionary> profileMap = new Map();
      _items.forEach((item) {
        profileMap[item.word] = item;
      });
      _items = profileMap.values.toList();
    });
    _suggestTextController.addListener(() {
      setState(() {});
    });
  }

    @override
    void initState() {
      _setup();
      super.initState();
    }

  void _setTextField(text) {
    _suggestTextController.value = TextEditingValue(
      text: text,
      selection: TextSelection.fromPosition(TextPosition(offset: text.length)),
    );
  }

    Future toggleRecording() => SpeechApi.toggleRecording(
        onResult: (text) => setState(() => _setTextField(text)),
        onListening: (isListening) {});

  @override
  void dispose() {
    _suggestTextController.dispose();
    super.dispose();
  }

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
          toolbarHeight: 110,
          backwardsCompatibility: false,
          title: Container(
              child: Column(
            children: <Widget>[
              SizedBox(
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "English - Vietnamese Dictionary",
                      style: GoogleFonts.laila(
                          fontWeight: FontWeight.w600,
                          fontSize: 27,
                          color: Colors.green),
                    ),
                  )),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                      child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 40,
                    child: Center(
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          autofocus: false,
                          controller: _suggestTextController,
                          style: DefaultTextStyle.of(context).style.copyWith(
                              fontStyle: FontStyle.italic, color: Colors.black),
                          onSubmitted: (String text) async {
                            try {
                              if (_suggestTextController.text.isEmpty) {
                                return EasyLoading.showError(
                                    "Vui lòng nhập từ cần tra");
                              }
                              Directory directory =
                                  await getExternalStorageDirectory();
                              var filePath =
                                  join(directory.path, "dictionary.db");
                              print(filePath);

                              var sql = await openDatabase(filePath);
                              var result = await sql.rawQuery(
                                  'SELECT * FROM dictionaries WHERE word="${_suggestTextController.text}"');

                              var jsonResult = result[0];

                              final id = db.collection('dictionaries').doc().id;
                              final data = Dictionary(
                                id: id,
                                word: jsonResult['word'],
                                form: jsonResult['form'],
                                pronunciation_uk:
                                    jsonResult['pronunciation_uk'],
                                pronunciation_us:
                                    jsonResult['pronunciation_us'],
                                definition: jsonResult['definitions'],
                                similar: jsonResult['similar'],
                                speciality: jsonResult['speciality'],
                              );
                              data.save();
                              var value =
                                  await db.collection('dictionaries').get();
                              List<Dictionary> _list = new List<Dictionary>();
                              setState(() {
                                _items.clear();
                                value?.entries?.forEach((element) => _list
                                    .add(Dictionary.fromMap(element.value)));

                                for (var i = 0; i < _list.length; i++) {
                                  _items.add(_list[_list.length - 1 - i]);
                                }

                                final Map<String, Dictionary> profileMap =
                                    new Map();
                                _items.forEach((item) {
                                  profileMap[item.word] = item;
                                });
                                _items = profileMap.values.toList();
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DictionarResult(
                                          result: data,
                                        )),
                              );
                            } catch (e) {
                              ConnectivityResult result =
                                  await (Connectivity().checkConnectivity());
                              if (result == ConnectivityResult.none) {
                                return EasyLoading.showToast(
                                    'Không tìm thấy từ này, vui lòng bật mạng và thử lại sau!');
                              }
                              EasyLoading.show();
                              var response;
                              var jsonRespone;
                              try {
                                var url = Uri.parse(
                                    '$baseURL/av?word=${_suggestTextController.text}');
                                response = await http.get(
                                  url,
                                  headers: {
                                    'Content-Type':
                                        'application/x-www-form-urlencoded',
                                    "token": "$token",
                                  },
                                );
                                jsonRespone = json.decode(response.body);
                              } catch (e) {
                                print(e);
                                return EasyLoading.showError(
                                    "Có lỗi xảy ra, vui lòng thử lại sau");
                              }
                              if (jsonRespone["definition"] == "" &&
                                  jsonRespone["similar"] == "" &&
                                  jsonRespone["speciality"] == "") {
                                return EasyLoading.showError(
                                    "Không tìm thấy từ này");
                              }
                              final id = db.collection('dictionaries').doc().id;
                              final data = Dictionary(
                                id: id,
                                word: jsonRespone['word'],
                                form: jsonRespone['form'],
                                pronunciation_uk:
                                    jsonRespone['pronunciation_uk'],
                                pronunciation_us:
                                    jsonRespone['pronunciation_us'],
                                definition: jsonRespone['definition'],
                                similar: jsonRespone['similar'],
                                speciality: jsonRespone['speciality'],
                              );
                              data.save();
                              var value =
                                  await db.collection('dictionaries').get();
                              List<Dictionary> _list = new List<Dictionary>();
                              setState(() {
                                _items.clear();
                                value?.entries?.forEach((element) => _list
                                    .add(Dictionary.fromMap(element.value)));

                                for (var i = 0; i < _list.length; i++) {
                                  _items.add(_list[_list.length - 1 - i]);
                                }

                                final Map<String, Dictionary> profileMap =
                                    new Map();
                                _items.forEach((item) {
                                  profileMap[item.word] = item;
                                });
                                _items = profileMap.values.toList();
                              });
                              EasyLoading.dismiss();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DictionarResult(
                                          result: data,
                                        )),
                              );
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1),
                            ),
                            // isDense: true,
                            hintText: "Enter the word to look up",
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.green,
                            ),
                            hintStyle: GoogleFonts.quicksand(
                                color: Color(0xFF777777), fontSize: 18),
                            errorBorder: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 1),
                            ),
                            disabledBorder: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                            alignLabelWithHint: true,
                            focusColor: Colors.grey,
                            contentPadding: EdgeInsets.only(top: 1, bottom: 1),
                            hintMaxLines: 1,
                            suffixIcon: _suggestTextController.text.length == 0
                                ? null // Show nothing if the text field is empty
                                : IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      _suggestTextController.clear();
                                    },
                                  ), // Show the clear button if the text field has something
                          ),
                        ),
                        suggestionsCallback: (pattern) async {
                          return await _loadSuggest(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                              leading: Icon(Icons.search),
                              title: Text(suggestion),
                              trailing: Icon(Icons.north_east));
                        },
                        onSuggestionSelected: (suggestion) async {
                          try {
                            Directory directory =
                                await getExternalStorageDirectory();
                            var filePath =
                                join(directory.path, "dictionary.db");
                            print(filePath);

                            var sql = await openDatabase(filePath);
                            var result = await sql.rawQuery(
                                'SELECT * FROM dictionaries WHERE word="$suggestion"');
                            print(result[0]);
                            var jsonResult = result[0];

                            final id = db.collection('dictionaries').doc().id;
                            final data = Dictionary(
                              id: id,
                              word: jsonResult['word'],
                              form: jsonResult['form'],
                              pronunciation_uk: jsonResult['pronunciation_uk'],
                              pronunciation_us: jsonResult['pronunciation_us'],
                              definition: jsonResult['definitions'],
                              similar: jsonResult['similar'],
                              speciality: jsonResult['speciality'],
                            );
                            data.save();
                            var value =
                                await db.collection('dictionaries').get();
                            List<Dictionary> _list = new List<Dictionary>();
                            setState(() {
                              _items.clear();
                              value?.entries?.forEach((element) =>
                                  _list.add(Dictionary.fromMap(element.value)));

                              for (var i = 0; i < _list.length; i++) {
                                _items.add(_list[_list.length - 1 - i]);
                              }

                              final Map<String, Dictionary> profileMap =
                                  new Map();
                              _items.forEach((item) {
                                profileMap[item.word] = item;
                              });
                              _items = profileMap.values.toList();
                              _items.forEach((element) {
                                print(element.word);
                              });
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DictionarResult(
                                        result: data,
                                      )),
                            );
                          } catch (e) {
                            ConnectivityResult result =
                                await (Connectivity().checkConnectivity());
                            if (result == ConnectivityResult.none) {
                              return EasyLoading.showToast(
                                  'Không tìm thấy từ này, vui lòng bật mạng và thử lại sau!');
                            }
                            var response;
                            var jsonRespone;
                            try {
                              var url =
                                  Uri.parse('$baseURL/av?word=$suggestion');
                              response = await http.get(
                                url,
                                headers: {
                                  'Content-Type':
                                      'application/x-www-form-urlencoded',
                                  "token": "$token",
                                },
                              );
                              jsonRespone = json.decode(response.body);
                            } catch (e) {
                              print(e);
                              EasyLoading.showError(
                                  "Có lỗi xảy ra, vui lòng thử lại sau");
                              return;
                            }
                            if (jsonRespone["definition"] == "" &&
                                jsonRespone["similar"] == "" &&
                                jsonRespone["speciality"] == "") {
                              return EasyLoading.showError(
                                  "Không tìm thấy từ này");
                            }
                            final id = db.collection('dictionaries').doc().id;
                            final data = Dictionary(
                              id: id,
                              word: jsonRespone['word'],
                              form: jsonRespone['form'],
                              pronunciation_uk: jsonRespone['pronunciation_uk'],
                              pronunciation_us: jsonRespone['pronunciation_us'],
                              definition: jsonRespone['definition'],
                              similar: jsonRespone['similar'],
                              speciality: jsonRespone['speciality'],
                            );
                            data.save();
                            var value =
                                await db.collection('dictionaries').get();
                            List<Dictionary> _list = new List<Dictionary>();
                            setState(() {
                              _items.clear();
                              value?.entries?.forEach((element) =>
                                  _list.add(Dictionary.fromMap(element.value)));

                              for (var i = 0; i < _list.length; i++) {
                                _items.add(_list[_list.length - 1 - i]);
                              }

                              final Map<String, Dictionary> profileMap =
                                  new Map();
                              _items.forEach((item) {
                                profileMap[item.word] = item;
                              });
                              _items = profileMap.values.toList();
                              // _items.forEach((element) {
                              //   print(element.word);
                              // });
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DictionarResult(
                                        result: data,
                                      )),
                            );
                          }
                        },
                        noItemsFoundBuilder: (context) {
                          return FlatButton(
                            child: ListTile(
                                leading: Icon(Icons.search),
                                title: Text(_suggestTextController.text),
                                trailing: Icon(Icons.north_east)),
                            onPressed: () async {
                              if (_suggestTextController.text.isEmpty) {
                                return EasyLoading.showError(
                                    "Vui lòng nhập từ cần tra");
                              }
                              try {
                                Directory directory =
                                    await getExternalStorageDirectory();
                                var filePath =
                                    join(directory.path, "dictionary.db");
                                print(filePath);

                                var sql = await openDatabase(filePath);
                                var result = await sql.rawQuery(
                                    'SELECT * FROM dictionaries WHERE word="${_suggestTextController.text}"');

                                var jsonResult = result[0];

                                final id =
                                    db.collection('dictionaries').doc().id;
                                final data = Dictionary(
                                  id: id,
                                  word: jsonResult['word'],
                                  form: jsonResult['form'],
                                  pronunciation_uk:
                                      jsonResult['pronunciation_uk'],
                                  pronunciation_us:
                                      jsonResult['pronunciation_us'],
                                  definition: jsonResult['definitions'],
                                  similar: jsonResult['similar'],
                                  speciality: jsonResult['speciality'],
                                );
                                data.save();
                                var value =
                                    await db.collection('dictionaries').get();
                                List<Dictionary> _list = new List<Dictionary>();
                                setState(() {
                                  _items.clear();
                                  value?.entries?.forEach((element) => _list
                                      .add(Dictionary.fromMap(element.value)));

                                  for (var i = 0; i < _list.length; i++) {
                                    _items.add(_list[_list.length - 1 - i]);
                                  }

                                  final Map<String, Dictionary> profileMap =
                                      new Map();
                                  _items.forEach((item) {
                                    profileMap[item.word] = item;
                                  });
                                  _items = profileMap.values.toList();
                                  _items.forEach((element) {
                                    print(element.word);
                                  });
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DictionarResult(
                                            result: data,
                                          )),
                                );
                              } catch (e) {
                                ConnectivityResult result =
                                    await (Connectivity().checkConnectivity());
                                if (result == ConnectivityResult.none) {
                                  return EasyLoading.showToast(
                                      'Không tìm thấy từ này, vui lòng bật mạng và thử lại sau!');
                                }
                                EasyLoading.show();
                                var response;
                                var jsonRespone;
                                try {
                                  var url = Uri.parse(
                                      '$baseURL/av?word=${_suggestTextController.text}');
                                  response = await http.get(
                                    url,
                                    headers: {
                                      'Content-Type':
                                          'application/x-www-form-urlencoded',
                                      "token": "$token",
                                    },
                                  );
                                  jsonRespone = json.decode(response.body);
                                } catch (e) {
                                  print(e);
                                  return EasyLoading.showError(
                                      "Có lỗi xảy ra, vui lòng thử lại sau");
                                }
                                if (jsonRespone["definition"] == "" &&
                                    jsonRespone["similar"] == "" &&
                                    jsonRespone["speciality"] == "") {
                                  return EasyLoading.showError(
                                      "Không tìm thấy từ này");
                                }
                                final id =
                                    db.collection('dictionaries').doc().id;
                                final data = Dictionary(
                                  id: id,
                                  word: jsonRespone['word'],
                                  form: jsonRespone['form'],
                                  pronunciation_uk:
                                      jsonRespone['pronunciation_uk'],
                                  pronunciation_us:
                                      jsonRespone['pronunciation_us'],
                                  definition: jsonRespone['definition'],
                                  similar: jsonRespone['similar'],
                                  speciality: jsonRespone['speciality'],
                                );
                                data.save();
                                EasyLoading.dismiss();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DictionarResult(
                                            result: data,
                                          )),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  )),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 40,
                      child: Container(
                        padding: EdgeInsets.only(right: 25),
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.green,
                              size: 33,
                            ),
                            onPressed: () async {
                              setState(() {
                                this.isListening = true;
                              });
                              await audioCache
                                  .play('audio/mic_start_sound.mp3');
                              await toggleRecording();
                              await Future.delayed(Duration(seconds: 2));
                              setState(() {
                                this.isListening = false;
                              });
                            },
                          ),
                        ),
                      )),
                ],
              ),
            ],
          )),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
        ),
        body: WillPopScope(
            onWillPop: onWillPop,
            child: Container(
                padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                child: _items.length != 0
                    ? ListView.builder(
                        itemCount: _items.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Column(
                            children: <Widget>[
                              Container(
                                height: 80,
                                width: MediaQuery.of(context).size.width * 0.9,
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.only(bottom: 15, top: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xffffffff),
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
                                child: FlatButton(
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 25,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  item.word,
                                                  style: GoogleFonts.quicksand(
                                                      color: Colors.green,
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              child: Container(
                                                  padding:
                                                      EdgeInsets.only(left: 10),
                                                  child: item.pronunciation_uk !=
                                                          null
                                                      ? HtmlWidget(
                                                          "<span style='font-size:18px;font-weight:400'>" +
                                                              item
                                                                  .pronunciation_uk +
                                                              "</span>")
                                                      : HtmlWidget(
                                                          "<span style='font-size:18px;font-weight:400'>" +
                                                              item.word +
                                                              "</span>")),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          child: Container(
                                        width: 60,
                                        height: 60,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Color(0xFF63F2D8),
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.volume_up,
                                            color: Colors.white,
                                            size: 33,
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              isListening = true;
                                            });
                                            await flutterTts
                                                .setLanguage('en-GB');
                                            await flutterTts.setVoice({
                                              "name": "en-gb-x-gbg-network",
                                              "locale": "en-GB"
                                            });
                                            await flutterTts.speak(item.word);
                                            await flutterTts
                                                .setCompletionHandler(() {
                                              setState(() {
                                                isListening = false;
                                              });
                                            });
                                          },
                                        ),
                                      ))
                                    ],
                                  ),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DictionarResult(result: item)),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        })
                    : Container())));
  }
}
