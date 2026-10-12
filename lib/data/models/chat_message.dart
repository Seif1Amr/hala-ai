import 'dialect.dart';

enum MessageSender { user, hala }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final DialectType dialect;
  final String? phonetic;
  final String? correction;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.dialect,
    this.phonetic,
    this.correction,
  });

  bool get isFromHala => sender == MessageSender.hala;
}
