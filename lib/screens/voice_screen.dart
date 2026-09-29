import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../services/profile_store.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../models/user_profile.dart';
import '../widgets/siko_avatar.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key, this.dayTalk = false});
  final bool dayTalk;

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final _speech = SpeechService();
  final _tts = TtsService();
  final _ai = const AiService();
  String _transcript = '';
  String _reply = '';
  bool _listening = false;
  bool _thinking = false;
  bool _speaking = false;
  String? _error;

  String get _localeId {
    final profile = ProfileStore.instance.profile!;
    if (profile.learningLanguage == 'French') return 'fr_FR';
    return profile.englishVariant == 'British' ? 'en_GB' : 'en_US';
  }

  String get _ttsLocale {
    final profile = ProfileStore.instance.profile!;
    if (profile.learningLanguage == 'French') return 'fr-FR';
    return profile.englishVariant == 'British' ? 'en-GB' : 'en-US';
  }

  @override
  void initState() {
    super.initState();
    _tts.onSpeakingChanged = (value) {
      if (mounted) setState(() => _speaking = value);
    };
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleListen() async {
    setState(() => _error = null);
    if (_listening) {
      await _speech.stop(onListeningChanged: (value) {
        if (mounted) setState(() => _listening = value);
      });
      return;
    }

    final started = await _speech.listen(
      localeId: _localeId,
      onText: (text) {
        if (mounted) setState(() => _transcript = text);
      },
      onListeningChanged: (value) {
        if (mounted) setState(() => _listening = value);
      },
    );

    if (!started && mounted) {
      setState(() => _error = 'لم أستطع تشغيل الميكروفون. تأكد من السماح بالميكروفون ووجود خدمة Speech Recognition على الجهاز.');
    }
  }

  Future<void> _sendVoiceText() async {
    final text = _transcript.trim();
    if (text.isEmpty || _thinking) return;
    setState(() {
      _thinking = true;
      _reply = '';
    });
    final reply = await _ai.reply(userText: text, profile: ProfileStore.instance.profile!);
    if (!mounted) return;
    setState(() {
      _reply = reply;
      _thinking = false;
    });
    await _tts.speak(reply, _ttsLocale);
  }

  @override
Widget build(BuildContext context) {
  final profile = ProfileStore.instance.profile!;

  final String statusText = _listening
      ? 'سيكو بيسمعك...'
      : _thinking
          ? 'سيكو بيفكر...'
          : _speaking
              ? 'سيكو بيتكلم وبيتفاعل...'
              : widget.dayTalk
                  ? 'احكي لي عن يومك بصوتك'
                  : 'اضغط الميكروفون واتكلم';

  final AvatarAnimationMode avatarMode = _listening
      ? AvatarAnimationMode.listening
      : _speaking
          ? AvatarAnimationMode.speaking
          : _thinking
              ? AvatarAnimationMode.thinking
              : AvatarAnimationMode.idle;

  return Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dayTalk
              ? 'احكي لي عن يومك'
              : 'المحادثة الصوتية',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
        children: [
          Center(
            child: SikoAvatar(
              imageBase64: profile.avatarBase64,
              imagePath: profile.avatarPath,
              preset: profile.avatarPreset,
              mode: avatarMode,
              size: 210,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              statusText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          if (_transcript.isNotEmpty) ...[
            Text(
              'اللي فهمته منك',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _transcript,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _thinking ? null : _sendVoiceText,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('خلي سيكو يرد'),
            ),
            const SizedBox(height: 16),
          ],
          if (_reply.isNotEmpty) ...[
            Text(
              'رد سيكو',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _reply,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ],
          if (_error != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!),
              ),
            ),
          const SizedBox(height: 26),
          Center(
            child: FloatingActionButton.large(
              onPressed: _toggleListen,
              child: Icon(
                _listening
                    ? Icons.stop_rounded
                    : Icons.mic_rounded,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'اللغة المستخدمة للاستماع: $_localeId',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    ),
  );
}