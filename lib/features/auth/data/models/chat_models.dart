import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final Timestamp? timeStamp;  // nullable now

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    this.timeStamp,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      id: doc.id,
      senderId: doc['senderId'] ?? '',
      text: doc['text'] ?? '',
      timeStamp: doc['timeStamp'] as Timestamp?,  // safely cast to nullable Timestamp
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timeStamp': FieldValue.serverTimestamp(),
    };
  }
}
