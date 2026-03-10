// AI service interface and common models.
enum ChatMessageType { user, sysetm }

class ChatMessage {
  ChatMessageType type;
  String message;

  ChatMessage({required this.type, this.message = ''});
}

abstract class AIService {
  String get modelName;

  Future<bool> connect();
  Future<String> sendMessage(String message);
  Future<void> disconnect();
}
