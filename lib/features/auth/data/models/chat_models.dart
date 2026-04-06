import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // to show time in the Chat Bubble (e.g., "12:45 PM")
  String get formattedTime {
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }

  factory Message.fromMap(Map<String, dynamic> map, String docId) {
    return Message(
      id: docId,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? map['timestamp']
          : Timestamp.now(),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}