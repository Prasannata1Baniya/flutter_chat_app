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

  /// Helper to show time in the Chat Bubble (e.g., "12:45 PM")
  String get formattedTime {
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }

  /// Factory to convert Firestore Map data into a Message Object
  /// Use this inside your Repository when mapping snapshot.docs
  factory Message.fromMap(Map<String, dynamic> map, String docId) {
    return Message(
      id: docId,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      // SAFETY: If the server hasn't set the time yet (pending state),
      // we use the current local time so the app doesn't crash.
      timestamp: map['timestamp'] is Timestamp
          ? map['timestamp']
          : Timestamp.now(),
    );
  }

  /// Convert Message Object to Map for sending to Firestore
  /// Use this inside your Repository's sendMessage function
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      // CRITICAL: Tells Firebase to use its own global clock for ordering.
      // This ensures messages "stay" in the same order for every user.
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}