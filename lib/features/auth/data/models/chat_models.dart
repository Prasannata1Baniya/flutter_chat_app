import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final Timestamp? timestamp; // Nullable to handle "Pending" state safely

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    this.timestamp,
  });

  String get formattedTime {
    if (timestamp == null) return "Sending...";
    return DateFormat('hh:mm a').format(timestamp!.toDate());
  }

  // Factory to convert Firestore Document to Message Object
  factory Message.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      // If the server hasn't set the time yet (local cache), this will be null
      timestamp: data['timestamp'] as Timestamp?,
    );
  }

  // Convert Message Object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
