import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechApi {
  static final _speech = new SpeechToText();

  static Future<bool> toggleRecording({
    @required Function(String text) onResult,
    @required ValueChanged<bool> onListening,
  }) async {
    final isAvailable = await _speech.initialize(
      onStatus: (status) => onListening(_speech.isListening),
      onError: (e) {
        _speech.stop();
        return print("Stop");
      },
    );

    if (isAvailable) {
      _speech.listen(
          onResult: (value) => onResult(value.recognizedWords),
          localeId: 'en_GB');
      return isAvailable;
    } else {
      print("The user has denied the use of speech recognition.");
    }
    _speech.stop();
    return false;
  }
}
