import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() {
    _tts.setCompletionHandler(() => onSpeakingChanged?.call(false));
    _tts.setCancelHandler(() => onSpeakingChanged?.call(false));
    _tts.setErrorHandler((_) => onSpeakingChanged?.call(false));
    _tts.setStartHandler(() => onSpeakingChanged?.call(true));
  }

  final FlutterTts _tts = FlutterTts();
  void Function(bool isSpeaking)? onSpeakingChanged;

  Future<void> speak(String text, String languageCode) async {
    await stop();
    await _tts.setLanguage(languageCode);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    onSpeakingChanged?.call(false);
  }
}
