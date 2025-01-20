import '../../data/models/chat_models.dart';

abstract class ChatRepo{
   Stream<List<Message>> getMessages(String chatID);
  Future<void> sendMessage(String chatId,Message message);

}