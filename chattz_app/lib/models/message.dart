class Message {
  final String id;
  final String text;
  final bool isAudio;
  final String? audioUrl;
  final String? audioDuration;
  final String? senderUserId;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    this.isAudio = false,
    this.audioUrl = "",
    this.audioDuration = "00:00",
    required this.senderUserId,
    required this.timestamp,
  });
}
