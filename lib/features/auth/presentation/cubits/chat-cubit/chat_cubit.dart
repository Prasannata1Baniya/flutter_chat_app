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

  // --- FETCH MESSAGES ---
  Future<void> fetchMessage(String chatID) async {
    // Only show loading if we aren't already listening to a stream
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

  // --- SEND MESSAGE ---
  Future<void> sendMessage(String text, String chatId, String senderId) async {
    try {
      // 1. Create a temporary local message for the UI
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
        senderId: senderId,
        text: text,
        timestamp: Timestamp.now(), // Local time for instant preview
      );

      // 2. OPTIONAL: If you want 'Optimistic UI', you could manually
      // emit a ChatLoaded state with the new message added here.
      // But for this demo, let's keep it simple and rely on the Stream.

      // 3. Send to Repo
      await _chatRepo.sendMessage(chatId, newMessage);

    } catch (e) {
      // If sending fails, we alert the UI
      emit(ChatError("Failed to send: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel(); // Critical for preventing memory leaks
    return super.close();
  }
}

