import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    _initialized = await _speech.initialize();
    return _initialized;
  }

  Future<bool> listen({
    required String localeId,
    required void Function(String text) onText,
    void Function(bool listening)? onListeningChanged,
  }) async {
    if (!_initialized && !await initialize()) return false;

    await _speech.listen(
      onResult: (result) => onText(result.recognizedWords),
      partialResults: true,
      localeId: localeId,
      listenMode: stt.ListenMode.dictation,
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 30),
    );
    onListeningChanged?.call(true);
    return true;
  }

  Future<void> stop({void Function(bool listening)? onListeningChanged}) async {
    await _speech.stop();
    onListeningChanged?.call(false);
  }
}
