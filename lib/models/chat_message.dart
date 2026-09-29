enum MessageAuthor { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.author,
    this.isVoice = false,
    this.timestamp,
  });

  final String text;
  final MessageAuthor author;
  final bool isVoice;
  final DateTime? timestamp;
}
