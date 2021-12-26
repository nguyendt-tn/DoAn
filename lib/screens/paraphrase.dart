import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' as html;
import 'package:google_fonts/google_fonts.dart';
import 'package:localstore/localstore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grammar_app/api/speech_api.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

import 'package:html/parser.dart';

class ParaphrasePage extends StatefulWidget {
  @override
  _ParaphrasePage createState() => _ParaphrasePage();
}

class _ParaphrasePage extends State<ParaphrasePage> {
  final translator = GoogleTranslator();

  bool isListening = false;
  bool isHearing = false;

  String _textResult;

  FlutterTts flutterTts = FlutterTts();
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache(fixedPlayer: AudioPlayer());
  pickGallery() async {
    final image = await ImagePicker().getImage(source: ImageSource.gallery);
    cropImage(File(image.path));
  }

  pickCamera() async {
    final image = await ImagePicker().getImage(source: ImageSource.camera);
    cropImage(File(image.path));
  }

  cropImage(File filePath) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: filePath.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Color(0xFF00B8BA),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio3x2,
          lockAspectRatio: false,
        ));
    if (croppedFile != null) {
      EasyLoading.show();
      try {
        String _resultString =
            await SimpleOcrPlugin.performOCR(croppedFile.path);
        var jsonResult = json.decode(_resultString);
        if (jsonResult['code'] != 200) {
          return EasyLoading.showError('Có lỗi xảy ra, vui lòng thử lại sau!');
        }
        var text = jsonResult['text'];
        text = text.replaceAll(RegExp(' +'), ' ');
        EasyLoading.dismiss();
        _translateController.value = TextEditingValue(
          text: text,
          selection:
              TextSelection.fromPosition(TextPosition(offset: text.length)),
        );
        setState(() {});
        return EasyLoading.dismiss();
      } catch (e) {
        return EasyLoading.showError('Có lỗi xảy ra, vui lòng thử lại sau!');
      }
    }
  }

  final TextEditingController _translateController = TextEditingController();
  void _clearTextField() {
    _translateController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _translateController.dispose();
    super.dispose();
  }

  void _setTextField(text) {
    _translateController.value = TextEditingValue(
      text: text,
      selection: TextSelection.fromPosition(TextPosition(offset: text.length)),
    );
  }

  Future toggleRecording() => SpeechApi.toggleRecording(
      onResult: (text) => setState(() => _setTextField(text)),
      onListening: (isListening) {});

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

  final db = Localstore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backwardsCompatibility: false,
          title: Text(
            "Paraphrase",
            style: GoogleFonts.laila(
                fontWeight: FontWeight.w600, fontSize: 27, color: Colors.green),
          ),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
        ),
        body: WillPopScope(
          onWillPop: onWillPop,
          child: Container(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Container(
                      padding: EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(20),
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
                          Container(
                              height:
                                  (MediaQuery.of(context).size.height * 0.35) -
                                      50,
                              child: TextField(
                                textInputAction: TextInputAction.done,
                                controller: _translateController,
                                minLines: 5,
                                maxLines: null,
                                style: TextStyle(fontSize: 19),
                                decoration: InputDecoration(
                                  hintText:
                                      'Click to enter the text to be paraphrase',
                                  hintStyle: TextStyle(fontSize: 20),
                                  labelStyle: TextStyle(fontSize: 18),
                                  hintMaxLines: 5,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                                autofocus: false,
                                onChanged: (value) {
                                  setState(() {});
                                },
                              )),
                          Container(
                            height: 50,
                            padding: EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                SizedBox(
                                  child: Row(
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(
                                          Icons.camera_alt,
                                          color: Color(0xFF00B8BA),
                                          size: 33,
                                        ),
                                        onPressed: () {
                                          pickCamera();
                                        },
                                      ),
                                      SizedBox(width: 10),
                                      IconButton(
                                        icon: Icon(
                                          Icons.photo_size_select_actual,
                                          color: Color(0xFF00B8BA),
                                          size: 33,
                                        ),
                                        onPressed: () {
                                          pickGallery();
                                        },
                                      ),
                                      SizedBox(width: 10),
                                      IconButton(
                                        icon: Icon(
                                          isListening
                                              ? Icons.mic
                                              : Icons.mic_none,
                                          color: Color(0xFF00B8BA),
                                          size: 33,
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            this.isListening = true;
                                          });
                                          await audioCache.play(
                                              'audio/mic_start_sound.mp3');
                                          await toggleRecording();
                                          await Future.delayed(
                                              Duration(seconds: 2));
                                          setState(() {
                                            this.isListening = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  child: _translateController.text.length == 0
                                      ? null
                                      : IconButton(
                                          icon: Icon(
                                            Icons.cancel_outlined,
                                            color: Color(0xff8391a0),
                                            size: 33,
                                          ),
                                          onPressed: () {
                                            _clearTextField();
                                          },
                                        ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  SizedBox(
                      child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      gradient: LinearGradient(
                          colors: [Color(0xFF00FFED), Color(0xFF00B8BA)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
                    ),
                    child: FlatButton(
                        child: Text(
                          "Paraphrase",
                          style: GoogleFonts.laila(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          if (_translateController.text.isEmpty) {
                            return EasyLoading.showToast(
                                'Please enter the English content you want to paraphrase!');
                          }
                          ConnectivityResult result =
                              await (Connectivity().checkConnectivity());
                          if (result == ConnectivityResult.none) {
                            return EasyLoading.showToast(
                                'Please turn on the network and try again later!');
                          }

                          var languageToolUri = Uri.https(
                              "www.rewritertools.com",
                              "rewritearticlepro.php",
                              {"action": "{rewrite}"});
                          print(languageToolUri);
                          var respone = await http.post(
                            languageToolUri,
                            body: {
                              "keep": "0",
                              "data": _translateController.text
                            },
                          );

                          if (respone.statusCode != 200) {
                            return EasyLoading.showError(
                                "An error occurred, please try again later");
                          }

                          // setState(() {
                          //   from = _firstLanguage == "English" ? "en" : "vi";
                          //   to = _secondLanguage == "English" ? "en" : "vi";
                          // });
                          // EasyLoading.show();
                          // var translation = await translator.translate(
                          //     _translateController.text,
                          //     from: from,
                          //     to: to);
                          EasyLoading.dismiss();
                          setState(() {
                            _textResult = respone.body;
                          });
                        }),
                  )),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  _textResult != null
                      ? SizedBox(
                          // height: MediaQuery.of(context).size.height * 0.2,
                          child: Container(
                            padding: EdgeInsets.only(left: 20),
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.circular(20),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(
                                      top: 20,
                                      bottom: 20,
                                      right: 8,
                                    ),
                                    child: SingleChildScrollView(
                                      // child: Text(
                                      //   _textResult,
                                      //   maxLines: null,
                                      //   style: GoogleFonts.quicksand(
                                      //       color: Colors.black,
                                      //       fontSize: 19,
                                      //       fontWeight: FontWeight.w600),
                                      // ),
                                      child: html.HtmlWidget(
                                        _textResult,
                                        textStyle: TextStyle(fontSize: 18),
                                        customStylesBuilder: (element) {
                                          if (element.classes
                                              .contains('qtiperar')) {
                                            return {'color': '#00B8BA'};
                                          }

                                          return null;
                                        },
                                      ),
                                    )),
                                Container(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SizedBox(
                                        child: Row(
                                          children: <Widget>[
                                            IconButton(
                                              icon: Icon(
                                                isHearing == true
                                                    ? Icons.volume_up
                                                    : Icons.volume_up_outlined,
                                                color: Color(0xFF00B8BA),
                                                size: 33,
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  isHearing = true;
                                                });
                                                 var document = parse(
                                                  _textResult);
                                                  
                                                String resultText = parse(document.body.text).documentElement.text;
                                                resultText = resultText.replaceAll(RegExp(r"(?! )\s+| \s+"), "");

                                                await flutterTts
                                                    .setLanguage("en-GB");
                                                await flutterTts
                                                    .speak(resultText);
                                                await flutterTts
                                                    .setCompletionHandler(() {
                                                  setState(() {
                                                    isHearing = false;
                                                  });
                                                });
                                              },
                                            ),
                                            SizedBox(width: 10),
                                            IconButton(
                                              icon: Icon(
                                                Icons.copy,
                                                color: Color(0xFF00B8BA),
                                                size: 33,
                                              ),
                                              onPressed: () {
                                                 var document = parse(
                                                  _textResult);
                                                  
                                                String resultText = parse(document.body.text).documentElement.text;

                                                Clipboard.setData(ClipboardData(
                                                    text: resultText.replaceAll(RegExp(r"(?! )\s+| \s+"), "")));
                                                EasyLoading.showToast(
                                                    "Copy successfull");
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ));
  }
}
