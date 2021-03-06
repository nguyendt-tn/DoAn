import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
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
import 'package:connectivity/connectivity.dart';

class TranslatePage extends StatefulWidget {
  @override
  _TranslatePage createState() => _TranslatePage();
}

class _TranslatePage extends State<TranslatePage> {
  final translator = GoogleTranslator();

  bool isListening = false;
  bool isHearing = false;

  String from;
  String to;
  String _firstLanguage = "English";
  String _secondLanguage = "Vietnamese";
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
            return EasyLoading.showError(
                'C?? l???i x???y ra, vui l??ng th??? l???i sau!');
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
          return EasyLoading.showError('C?? l???i x???y ra, vui l??ng th??? l???i sau!');
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
      EasyLoading.showToast('B???m l???n n???a ????? tho??t ???ng d???ng');
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
            "Translate",
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
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Container(
                              child: Center(
                                child: Text(
                                  _firstLanguage,
                                  style: GoogleFonts.laila(
                                      color: Colors.grey[700],
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Container(
                              child: Center(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.compare_arrows,
                                    color: Colors.grey[700],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      String temp = _firstLanguage;
                                      _firstLanguage = _secondLanguage;
                                      _secondLanguage = temp;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Container(
                              child: Center(
                                child: Text(
                                  _secondLanguage,
                                  style: GoogleFonts.laila(
                                      color: Colors.grey[700],
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
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
                                  hintText: 'Click to enter the text to be translate',
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
                          "Translate",
                          style: GoogleFonts.laila(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          if (_translateController.text.isEmpty) {
                            return EasyLoading.showToast(
                                'Vui l??ng nh???p n???i dung ti???ng Anh mu???n d???ch!');
                          }
                          ConnectivityResult result =
                              await (Connectivity().checkConnectivity());
                          if (result == ConnectivityResult.none) {
                            return EasyLoading.showToast(
                                'Kh??ng t??m th???y t??? n??y, vui l??ng b???t m???ng v?? th??? l???i sau!');
                          }
                          setState(() {
                            from = _firstLanguage == "English" ? "en" : "vi";
                            to = _secondLanguage == "English" ? "en" : "vi";
                          });
                          EasyLoading.show();
                          var translation = await translator.translate(
                              _translateController.text,
                              from: from,
                              to: to);
                          EasyLoading.dismiss();
                          setState(() {
                            _textResult = translation.text;
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
                                      child: Text(
                                        _textResult,
                                        maxLines: null,
                                        style: GoogleFonts.quicksand(
                                            color: Colors.black,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w600),
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
                                                String language;
                                                language = to == "en"
                                                    ? "en-GB"
                                                    : "vi-VN";
                                                await flutterTts
                                                    .setLanguage(language);
                                                await flutterTts
                                                    .speak(_textResult);
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
                                                Clipboard.setData(ClipboardData(
                                                    text: _textResult));
                                                EasyLoading.showToast(
                                                    "???? l??u th??nh c??ng");
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
