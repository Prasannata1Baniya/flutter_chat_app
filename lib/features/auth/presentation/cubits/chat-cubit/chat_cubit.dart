import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/auth/data/models/chat_models.dart';

import '../../../domain/repo/chat_repo.dart';
import 'chat_state.dart';


class ChatCubit extends Cubit<ChatState>{
  final ChatRepo _chatRepo;
  ChatCubit(this._chatRepo):super(ChatInitial());

  //fetch message
  Future<void> fetchMessage(String chatID) async{
    emit(ChatLoading());
    try{
      _chatRepo.getMessages(chatID).listen((messages) {
        emit(ChatLoaded(messages));
      });

    }catch(e){
      emit(ChatError(e.toString()));
    }
  }


  //send message
  Future<void> sendMessage(String text, String chatId,String senderId) async{
  final message=Message(
      id: '',
      senderId: senderId,
      text: text,
      timeStamp: Timestamp.now(),
  );
  await _chatRepo.sendMessage(chatId, message);
  }
}