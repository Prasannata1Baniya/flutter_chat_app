import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final Timestamp? timestamp; // Nullable for pending messages

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Factory to convert Firestore Document to Message Object
  factory Message.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      // FIX: Handle the "Pending" null state safely
      timestamp: data['timestamp'] as Timestamp?,
    );
  }

  // Convert Message Object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      // FIX: Ensure the key matches the one in fromDocument ('timestamp')
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}



/*import 'package:cloud_firestore/cloud_firestore.dart';

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
      timeStamp: doc['timeStamp'] as Timestamp?,
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
*/