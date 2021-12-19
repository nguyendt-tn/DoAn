import 'dart:convert';
import 'package:grammar_app/models/grammar.dart';
import 'package:flutter/gestures.dart';
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
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';

class CheckPage extends StatefulWidget {
  @override
  _CheckPage createState() => _CheckPage();
}

class _CheckPage extends State<CheckPage> {
  bool isListening = false;
  String baseURL = "api.languagetoolplus.com";
  List<TextSpan> spans = [];
  bool isChecked = false;
  bool isShowError = false;
  int numError = 0;
  List<String> fixs = [];

  Grammar grammar;

  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache(fixedPlayer: AudioPlayer());

  Color getColor(String type) {
    if (type == 'grammar') {
      return Colors.red[700];
    }
    if (type == 'typographical') {
      return Colors.orange[700];
    }
    if (type == 'misspelling') {
      return Colors.blue[700];
    }
    return Colors.orange[500];
  }

  Color getBackground(String type) {
    if (type == 'grammar') {
      return Colors.red[100];
    }
    if (type == 'typographical') {
      return Colors.orange[100];
    }
    if (type == 'misspelling') {
      return Colors.blue[100];
    }
    return Colors.orange[50];
  }

  String getErrorMessage(String type, String shortMessage) {
    type = type.isNotEmpty ? type.capitalize() : "";
    shortMessage = shortMessage.isNotEmpty ? ": " + shortMessage : "";
    return type + shortMessage;
  }

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
        _checkController.value = TextEditingValue(
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

  final TextEditingController _checkController = TextEditingController();
  void _clearTextField() {
    _checkController.clear();
    setState(() {});
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
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _setTextField(text) {
    setState(() {
      _checkController.value = TextEditingValue(
        text: text,
        selection:
            TextSelection.fromPosition(TextPosition(offset: text.length)),
      );
    });
  }

  Future toggleRecording() => SpeechApi.toggleRecording(
        onResult: (text) => setState(() => _setTextField(text)),
        onListening: (isListening) {},
      );

  final db = Localstore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          backwardsCompatibility: false,
          title: Text(
            "Grammar Checker",
            style: GoogleFonts.laila(
                fontWeight: FontWeight.w600, fontSize: 27, color: Colors.green),
          ),
          elevation: 0,
        ),
        floatingActionButton: isChecked
            ? Container(
                margin: EdgeInsets.only(bottom: 165),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Color(0xFF00B8BA),
                    borderRadius: BorderRadius.circular(30)),
                child: IconButton(
                  alignment: Alignment.center,
                  icon: Icon(Icons.edit),
                  iconSize: 30,
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      isChecked = false;
                    });
                  },
                ),
              )
            : null,
        body: WillPopScope(
            onWillPop: onWillPop,
            child: isChecked == false
                ? Container(
                    padding: EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
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
                                    offset: Offset(
                                        0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                      height:
                                          (MediaQuery.of(context).size.height *
                                                  0.35) -
                                              50,
                                      child: TextField(
                                        textInputAction: TextInputAction.done,
                                        controller: _checkController,
                                        minLines: 5,
                                        maxLines: null,
                                        style: TextStyle(fontSize: 19),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Click to enter the text to fix the error method English',
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                                  Icons
                                                      .photo_size_select_actual,
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
                                            child: Row(
                                          children: <Widget>[
                                            SizedBox(
                                              child: _checkController
                                                          .text.length ==
                                                      0
                                                  ? null
                                                  : IconButton(
                                                      icon: Icon(
                                                        Icons.file_copy,
                                                        color:
                                                            Color(0xFF00B8BA),
                                                        size: 33,
                                                      ),
                                                      onPressed: () {
                                                        Clipboard.setData(
                                                            ClipboardData(
                                                                text:
                                                                    _checkController
                                                                        .text));
                                                        EasyLoading.showToast(
                                                            "Đã lưu thành công");
                                                      },
                                                    ),
                                            ),
                                            SizedBox(
                                              child: _checkController
                                                          .text.length ==
                                                      0
                                                  ? null
                                                  : IconButton(
                                                      icon: Icon(
                                                        Icons.cancel_outlined,
                                                        color:
                                                            Color(0xff8391a0),
                                                        size: 33,
                                                      ),
                                                      onPressed: () {
                                                        _clearTextField();
                                                      },
                                                    ),
                                            ),
                                          ],
                                        )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          SizedBox(
                              child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF00FFED),
                                    Color(0xFF00B8BA)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight),
                            ),
                            child: FlatButton(
                              child: Text(
                                "Check",
                                style: GoogleFonts.laila(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () async {
                                if (_checkController.text.isEmpty) {
                                  return EasyLoading.showToast(
                                      'Vui lòng nhập nội dung tiếng Anh muốn sửa lỗi!');
                                }
                                ConnectivityResult result =
                                    await (Connectivity().checkConnectivity());
                                if (result == ConnectivityResult.none) {
                                  return EasyLoading.showToast(
                                      'Không có kết nối, vui lòng bật mạng và thử lại sau!');
                                }
                                EasyLoading.show();
                                var _headers = {
                                  'Content-Type':
                                      'application/x-www-form-urlencoded',
                                  'Accept': 'application/json',
                                };
                                var languageToolUri =
                                    Uri.https(baseURL, "v2/check");
                                var respone = await http.post(
                                  languageToolUri,
                                  headers: _headers,
                                  body: {
                                    "language": "auto",
                                    "text": _checkController.text
                                  },
                                );
                                if (respone.statusCode != 200) {
                                  return EasyLoading.showError(
                                      "Có lỗi xảy ra, vui lòng thử lại sau");
                                }
                                try {
                                  spans.clear();
                                  fixs.clear();
                                  var jsonResult = json
                                      .decode(utf8.decode(respone.bodyBytes));

                                  var matches = jsonResult['matches'];
                                  var spanText = _checkController.text;
                                  var index = 0;
                                  var indexError = 0;
                                  var spanIndex = 0;

                                  numError = matches.length;
                                  if (numError == 0) {
                                    EasyLoading.showSuccess(
                                        'Looks good. No mistakes were found.');
                                    return;
                                  }
                                  for (var mistake in matches) {
                                    setState(() {
                                      String beforeSpan = spanText.substring(
                                          spanIndex, mistake['offset']);
                                      // if (mistake['offset'] == 0) {
                                      //   indexError += 0;
                                      // } else if (numError == 1) {
                                      //   indexError += 1;
                                      // } else {
                                      //   indexError += 2;
                                      // }
                                      spanIndex += beforeSpan.length;

                                      String errorSpan = spanText.substring(
                                          mistake['offset'],
                                          spanIndex + mistake['length']);
                                      index++;
                                      fixs.add(beforeSpan);
                                      fixs.add(errorSpan);
                                      spans.add(TextSpan(
                                          text: beforeSpan,
                                          style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                              color: Colors.black)));
                                      indexError += 2;
                                      mistake['indexError'] = indexError;
                                      spans.add(TextSpan(
                                          text: errorSpan,
                                          style: GoogleFonts.quicksand(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                            color: Colors.black,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: getColor(
                                                mistake['rule']['issueType']),
                                            backgroundColor: getBackground(
                                                mistake['rule']['issueType']),
                                            decorationThickness: 2.5,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              List<String> replace = [];
                                              mistake['replacements'].forEach(
                                                  (item) => {
                                                        replace
                                                            .add(item['value'])
                                                      });
                                              setState(() {
                                                isShowError = true;
                                                grammar = Grammar(
                                                    index:
                                                        mistake['indexError'] -
                                                            1,
                                                    offset: mistake['offset'],
                                                    type: mistake['rule']
                                                        ['issueType'],
                                                    shortMessage:
                                                        mistake['shortMessage'],
                                                    replace: replace,
                                                    errorWord: errorSpan,
                                                    message:
                                                        mistake['message']);
                                              });
                                            }));
                                      spanIndex += errorSpan.length;
                                      if (index == matches.length) {
                                        String endSpan = spanText.substring(
                                            spanIndex, spanText.length);
                                        spans.add(TextSpan(
                                            text: endSpan,
                                            style: GoogleFonts.quicksand(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 20,
                                                color: Colors.black)));
                                                fixs.add(endSpan);
                                      }
                                    });
                                  }
                                  isChecked = true;
                                  EasyLoading.dismiss();
                                  return;
                                } catch (e) {
                                  EasyLoading.showError(
                                      "Có lỗi xảy ra, vui lòng thử lại sau");
                                  return;
                                }
                              },
                            ),
                          )),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          isShowError
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.50,
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    child: SingleChildScrollView(
                                      physics: BouncingScrollPhysics(),
                                      child: RichText(
                                          text: TextSpan(
                                              children: List.from(spans))),
                                    ),
                                    padding: EdgeInsets.all(10),
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.topLeft,
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: RichText(
                                        text: TextSpan(
                                            children: List.from(spans))),
                                  ),
                                  padding: EdgeInsets.all(10),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          isShowError != false && numError != 0
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.22,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(10),
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
                                  child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.emoji_objects,
                                              color: getColor(grammar.type),
                                              size: 24,
                                            ),
                                            Text(" "),
                                            Text(
                                              getErrorMessage(grammar.type,
                                                  grammar.shortMessage),
                                              style: GoogleFonts.quicksand(
                                                  fontWeight: FontWeight.w700,
                                                  color: getColor(grammar.type),
                                                  fontSize: 20),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                grammar.errorWord != null
                                                    ? grammar.errorWord
                                                    : "",
                                                style: GoogleFonts.quicksand(
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    decorationColor: Colors.red,
                                                    decorationStyle:
                                                        TextDecorationStyle
                                                            .solid,
                                                    fontSize: 19),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Icon(
                                                Icons.arrow_forward,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            grammar.replace != null
                                                ? Wrap(
                                                    children: grammar.replace
                                                        .map((item) => InkWell(
                                                              onTap: () async {
                                                                setState(() {
                                                                  numError--;
                                                                  spans[
                                                                      grammar
                                                                          .index] = TextSpan(
                                                                      text:
                                                                          item,
                                                                      style: GoogleFonts.quicksand(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          fontSize:
                                                                              20,
                                                                          color:
                                                                              Colors.black));
                                                                  fixs[grammar
                                                                          .index] =
                                                                      item;
                                                                  isShowError =
                                                                      false;
                                                                });
                                                                if (numError ==
                                                                    0) {
                                                                  String
                                                                      result =
                                                                      fixs.join(
                                                                          "");
                                                                  setState(() {
                                                                    _checkController
                                                                            .text =
                                                                        result;
                                                                  });
                                                                  EasyLoading
                                                                      .show();
                                                                  var _headers =
                                                                      {
                                                                    'Content-Type':
                                                                        'application/x-www-form-urlencoded',
                                                                    'Accept':
                                                                        'application/json',
                                                                  };
                                                                  var languageToolUri =
                                                                      Uri.https(
                                                                          baseURL,
                                                                          "v2/check");
                                                                  var respone =
                                                                      await http
                                                                          .post(
                                                                    languageToolUri,
                                                                    headers:
                                                                        _headers,
                                                                    body: {
                                                                      "language":
                                                                          "auto",
                                                                      "text":
                                                                          _checkController
                                                                              .text
                                                                    },
                                                                  );
                                                                  if (respone
                                                                          .statusCode !=
                                                                      200) {
                                                                    return EasyLoading
                                                                        .showError(
                                                                            "Có lỗi xảy ra, vui lòng thử lại sau");
                                                                  }
                                                                  try {
                                                                    spans
                                                                        .clear();
                                                                    fixs.clear();
                                                                    var jsonResult =
                                                                        json.decode(
                                                                            utf8.decode(respone.bodyBytes));

                                                                    var matches =
                                                                        jsonResult[
                                                                            'matches'];
                                                                    var spanText =
                                                                        _checkController
                                                                            .text;
                                                                    var index =
                                                                        0;
                                                                    var indexError =
                                                                        0;
                                                                    var spanIndex =
                                                                        0;

                                                                    setState(
                                                                        () {
                                                                      numError =
                                                                          matches
                                                                              .length;
                                                                    });
                                                                    if (numError ==
                                                                        0) {
                                                                      setState(
                                                                          () {
                                                                        isChecked =
                                                                            false;
                                                                      });
                                                                      EasyLoading
                                                                          .showSuccess(
                                                                              'Looks good. No mistakes were found.');
                                                                    }
                                                                    for (var mistake
                                                                        in matches) {
                                                                      setState(
                                                                          () {
                                                                        String beforeSpan = spanText.substring(
                                                                            spanIndex,
                                                                            mistake['offset']);
                                                                        // if (mistake['offset'] ==
                                                                        //     0) {
                                                                        //   indexError +=
                                                                        //       0;
                                                                        // } else if (numError ==
                                                                        //     1) {
                                                                        //   indexError +=
                                                                        //       1;
                                                                        // } else {
                                                                        //   indexError +=
                                                                        //       2;
                                                                        // }
                                                                        spanIndex +=
                                                                            beforeSpan.length;

                                                                        String errorSpan = spanText.substring(
                                                                            mistake[
                                                                                'offset'],
                                                                            spanIndex +
                                                                                mistake['length']);
                                                                        index++;
                                                                        fixs.add(
                                                                            beforeSpan);
                                                                        fixs.add(
                                                                            errorSpan);
                                                                        spans.add(TextSpan(
                                                                            text:
                                                                                beforeSpan,
                                                                            style: GoogleFonts.quicksand(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 20,
                                                                                color: Colors.black)));
                                                                        indexError +=
                                                                            2;
                                                                        mistake['indexError'] =
                                                                            indexError;

                                                                        spans.add(TextSpan(
                                                                            text: errorSpan,
                                                                            style: GoogleFonts.quicksand(
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: 20,
                                                                              color: Colors.black,
                                                                              decoration: TextDecoration.underline,
                                                                              decorationColor: getColor(mistake['rule']['issueType']),
                                                                              backgroundColor: getBackground(mistake['rule']['issueType']),
                                                                              decorationThickness: 2.5,
                                                                            ),
                                                                            recognizer: TapGestureRecognizer()
                                                                              ..onTap = () {
                                                                                List<String> replace = [];
                                                                                mistake['replacements'].forEach((item) => {
                                                                                      replace.add(item['value'])
                                                                                    });
                                                                                setState(() {
                                                                                  isShowError = true;
                                                                                  grammar = Grammar(index: mistake['indexError'] - 1, offset: mistake['offset'], type: mistake['rule']['issueType'], shortMessage: mistake['shortMessage'], replace: replace, errorWord: errorSpan, message: mistake['message']);
                                                                                });
                                                                              }));
                                                                        spanIndex +=
                                                                            errorSpan.length;
                                                                        if (index ==
                                                                            matches.length) {
                                                                          String
                                                                              endSpan =
                                                                              spanText.substring(spanIndex, spanText.length);
                                                                          spans.add(TextSpan(
                                                                              text: endSpan,
                                                                              style: GoogleFonts.quicksand(fontWeight: FontWeight.w500, fontSize: 20, color: Colors.black)));
                                                                              fixs.add(endSpan);
                                                                        }
                                                                      });
                                                                    }
                                                                    EasyLoading
                                                                        .dismiss();
                                                                  } catch (e) {
                                                                    EasyLoading
                                                                        .showError(
                                                                            "Có lỗi xảy ra, vui lòng thử lại sau");
                                                                  }
                                                                }
                                                              },
                                                              child: FittedBox(
                                                                fit: BoxFit
                                                                    .contain,
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              10,
                                                                          bottom:
                                                                              10),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Color(
                                                                        0xFF00B8BA),
                                                                  ),
                                                                  child: Text(
                                                                    item,
                                                                    style: GoogleFonts.quicksand(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                ),
                                                              ),
                                                            ))
                                                        .toList(),
                                                  )
                                                : null
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          grammar.message != null
                                              ? grammar.message
                                              : null,
                                          style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ))
                              : Offstage(
                                  offstage: true,
                                ),
                        ]))));
  }
}
