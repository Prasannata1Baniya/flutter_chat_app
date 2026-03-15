import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/data/models/chat_models.dart';
import 'package:flutter_chat_app/features/auth/domain/repo/chat_repo.dart';

class ChatRepoImpl implements ChatRepo {
  final FirebaseFirestore _firestore;

  ChatRepoImpl(this._firestore);

  @override
  Stream<List<Message>> getMessages(String chatID) {
    // Added .orderBy('timestamp') to ensure messages are in chronological order
    return _firestore
        .collection('chats')
        .doc(chatID)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Newest at bottom
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
    });
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    try {
      // FIX: Ensure every message has a Server Timestamp
      // Using FieldValue.serverTimestamp() is more accurate than local device time
      final messageData = message.toMap();
      messageData['timestamp'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

    } catch (e) {
      debugPrint("Error sending message: $e");
      throw Exception("Check your internet connection and try again.");
    }
  }
}


/*class ChatRepoImpl implements ChatRepo {
  final FirebaseFirestore _firestore;

  ChatRepoImpl(this._firestore);

  @override
  Stream<List<Message>> getMessages(String chatID) {
    return _firestore.collection('chats/$chatID/messages').snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
      },
    );
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    try {
      await _firestore.collection('chats/$chatId/messages').add(message.toMap());
    } catch (e) {
      debugPrint("Error sending message: $e");
      throw Exception("Failed to send message");
    }
  }
}*/