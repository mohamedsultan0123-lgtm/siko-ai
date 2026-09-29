import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../services/ai_service.dart';
import '../services/profile_store.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../widgets/siko_avatar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _ai = const AiService();
  final _speech = SpeechService();
  final _tts = TtsService();
  final List<ChatMessage> _messages = [];
  bool _thinking = false;
  bool _speaking = false;
  bool _listening = false;

  UserProfile get _profile => ProfileStore.instance.profile!;

  String get _localeId {
    if (_profile.learningLanguage == 'French') return 'fr_FR';
    return _profile.englishVariant == 'British' ? 'en_GB' : 'en_US';
  }

  String get _ttsLocale {
    if (_profile.learningLanguage == 'French') return 'fr-FR';
    return _profile.englishVariant == 'British' ? 'en-GB' : 'en-US';
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
    _controller.dispose();
    _scrollController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      await _speech.stop(onListeningChanged: (v) {
        if (mounted) setState(() => _listening = v);
      });
      if (_controller.text.trim().isNotEmpty) await _send();
      return;
    }

    final started = await _speech.listen(
      localeId: _localeId,
      onText: (text) {
        if (mounted) setState(() => _controller.text = text);
      },
      onListeningChanged: (v) {
        if (mounted) setState(() => _listening = v);
      },
    );
    if (!started && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لم أستطع تشغيل الميكروفون. اسمح باستخدام الميكروفون من المتصفح أو الهاتف.')));
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _thinking) return;
    _controller.clear();
    if (_listening) await _speech.stop(onListeningChanged: (_) {});

    setState(() {
      _listening = false;
      _messages.add(ChatMessage(text: text, author: MessageAuthor.user, timestamp: DateTime.now()));
      _thinking = true;
    });
    _jumpToEnd();

    final reply = await _ai.reply(userText: text, profile: _profile);
    if (!mounted) return;
    setState(() {
      _thinking = false;
      _messages.add(ChatMessage(text: reply, author: MessageAuthor.assistant, timestamp: DateTime.now()));
    });
    _jumpToEnd();
  }

  void _jumpToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final mode = _listening
        ? AvatarAnimationMode.listening
        : _thinking
            ? AvatarAnimationMode.thinking
            : _speaking
                ? AvatarAnimationMode.speaking
                : AvatarAnimationMode.idle;
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Theme.of(context).colorScheme.primary.withOpacity(.12), Theme.of(context).colorScheme.surface],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('محادثة مع ${profile.safeAssistantName}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.tune_rounded)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 206,
                    child: SikoAvatar(
                      imageBase64: profile.avatarBase64,
                      imagePath: profile.avatarPath,
                      preset: profile.avatarPreset,
                      mode: mode,
                      size: 190,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_rounded, size: 15, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 7),
                        Text(
                          _listening ? 'سيكو بيسمعك' : _thinking ? 'سيكو بيفكر' : _speaking ? 'سيكو بيتكلم' : 'المحادثة شغالة',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 6),
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: _listening ? Colors.orange : Colors.green, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? _EmptyChat(profileName: profile.userName, onPrompt: (prompt) { _controller.text = prompt; _send(); })
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    itemCount: _messages.length + (_thinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_thinking && index == _messages.length) return const _ThinkingBubble();
                      final message = _messages[index];
                      return _MessageBubble(message: message, onSpeak: message.author == MessageAuthor.assistant ? () => _tts.speak(message.text, _ttsLocale) : null);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Material(
                    color: _listening ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.primaryContainer,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'الميكروفون',
                      onPressed: _thinking ? null : _toggleMic,
                      icon: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: 'اكتب لسيكو أو استخدم الميكروفون...', prefixIcon: Icon(Icons.chat_outlined)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 'chat_send',
                    onPressed: _thinking ? null : _send,
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.profileName, required this.onPrompt});
  final String profileName;
  final void Function(String) onPrompt;

  @override
  Widget build(BuildContext context) {
    final prompts = ['عرف نفسك', 'عايز أتعلم إنجليزي', 'عايز أتعلم فرنسي', 'ممكن نتكلم عن يومي؟'];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('أهلاً $profileName 👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('ابدأ بكلمة واحدة، وسيكو يكمل معاك المحادثة.', textAlign: TextAlign.center),
            const SizedBox(height: 18),
            Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: prompts.map((p) => ActionChip(label: Text(p), onPressed: () => onPrompt(p))).toList()),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.onSpeak});
  final ChatMessage message;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    final isUser = message.author == MessageAuthor.user;
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.fromLTRB(14, 11, 8, 8),
        decoration: BoxDecoration(
          color: isUser ? scheme.primaryContainer : scheme.surfaceContainerHighest.withOpacity(.72),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: Text(message.text, style: const TextStyle(fontSize: 16, height: 1.45))),
            if (onSpeak != null) IconButton(onPressed: onSpeak, icon: const Icon(Icons.volume_up_outlined), visualDensity: VisualDensity.compact),
          ],
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(18)),
        child: const SizedBox(width: 46, child: LinearProgressIndicator(minHeight: 4)),
      ),
    );
  }
}
