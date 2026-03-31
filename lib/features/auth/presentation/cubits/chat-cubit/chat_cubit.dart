import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/auth/data/models/chat_models.dart';
import '../../../domain/repo/chat_repo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;
  StreamSubscription<List<Message>>? _messageSubscription;

  ChatCubit(this._chatRepo) : super(ChatInitial());

  //Fetch MESSAGES
  Future<void> fetchMessage(String chatID) async {
    if (state is! ChatLoaded) emit(ChatLoading());

    try {
      await _messageSubscription?.cancel();

      _messageSubscription = _chatRepo.getMessages(chatID).listen(
            (messages) {
          emit(ChatLoaded(messages));
        },
        onError: (e) {
          emit(ChatError("Check your connection: ${e.toString()}"));
        },
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // Send MESSAGE
  Future<void> sendMessage(String text, String chatId, String senderId) async {
    try {
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        text: text,
        timestamp: Timestamp.now(),
      );

      await _chatRepo.sendMessage(chatId, newMessage);

    } catch (e) {
      // If sending fails, alerting the UI
      emit(ChatError("Failed to send: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel(); //for preventing memory leaks
    return super.close();
  }
}

