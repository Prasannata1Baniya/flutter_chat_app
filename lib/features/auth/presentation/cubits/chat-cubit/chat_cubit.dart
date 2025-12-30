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

  Future<void> fetchMessage(String chatID) async {
    emit(ChatLoading());
    try {
      await _messageSubscription?.cancel();

      _messageSubscription =
          _chatRepo.getMessages(chatID).listen(
                (messages) {
              emit(ChatLoaded(messages));
            },
            onError: (e) {
              emit(ChatError(e.toString()));
            },
          );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage(
      String text,
      String chatId,
      String senderId,
      ) async {
    try {
      final message = Message(
        id: '',
        senderId: senderId,
        text: text,
        timeStamp: Timestamp.now(),
      );

      await _chatRepo.sendMessage(chatId, message);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
