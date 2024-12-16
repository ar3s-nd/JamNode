class Message {
  final String id;
  final String text;
  final bool isLog;
  final String? senderUserId;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.senderUserId,
    required this.timestamp,
    this.isLog = false,
  });
}
