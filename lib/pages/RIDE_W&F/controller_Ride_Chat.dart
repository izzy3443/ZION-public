// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zion3/models/chat_model.dart';

// Stream<List<ChatMessage>> getMessages(String rideId) {
//   return FirebaseFirestore.instance
//       .collection('trip_req')
//       .doc(rideId)
//       .collection('messages')
//       .orderBy('timestamp', descending: false)
//       .snapshots()
//       .map((snapshot) =>
//           snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList());
// }

// final unreadMessageCountProvider =
//     StreamProvider.family<int, ({String rideId, String userId})>(
//   (ref, args) {
//     return FirebaseFirestore.instance
//         .collection('trip_req')
//         .doc(args.rideId)
//         .collection('messages')
//         .where('readBy.${args.userId}', isEqualTo: false)
//         .snapshots()
//         .map((snap) => snap.docs.length);
//   },
// );
// Future<void> sendMessage(
//   WidgetRef ref,
//   String text,
//   String currentUserId,
//   String receiverId,
//   String rideId,
// ) async {
//   final message = ChatMessage(
//     senderId: currentUserId,
//     text: text,
//     timestamp: DateTime.now(),
//     readBy: {
//       currentUserId: true,
//       receiverId: false, // 👈 Use real receiver UID here
//     },
//   );

//   await FirebaseFirestore.instance
//       .collection('trip_req')
//       .doc(rideId)
//       .collection('messages')
//       .add(message.toMap());
// }

// Future<void> markMessagesAsRead(String rideId, String currentUserId) async {
//   final messages = await FirebaseFirestore.instance
//       .collection('trip_req')
//       .doc(rideId)
//       .collection('messages')
//       .where('readBy.$currentUserId', isEqualTo: false)
//       .get();

//   final batch = FirebaseFirestore.instance.batch();

//   for (var doc in messages.docs) {
//     batch.update(doc.reference, {
//       'readBy.$currentUserId': true,
//     });
//   }

//   await batch.commit();
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion3/models/chat_model.dart';

// ---------------------------------------------------------------------------
// Stream — ordered ascending so the list view (reverse:true) shows newest last
// ---------------------------------------------------------------------------
Stream<List<ChatMessage>> getMessages(String rideId) {
  return FirebaseFirestore.instance
      .collection('trip_req')
      .doc(rideId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList());
}

// ---------------------------------------------------------------------------
// Unread-badge count for a given ride + user pair
// ---------------------------------------------------------------------------
final unreadMessageCountProvider =
    StreamProvider.family<int, ({String rideId, String userId})>(
  (ref, args) => FirebaseFirestore.instance
      .collection('trip_req')
      .doc(args.rideId)
      .collection('messages')
      .where('readBy.${args.userId}', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs.length),
);

// ---------------------------------------------------------------------------
// Send a message — marks sender as read, receiver as unread
// ---------------------------------------------------------------------------
Future<void> sendMessage({
  required WidgetRef ref,
  required String text,
  required String senderId,
  required String receiverId,
  required String rideId,
}) async {
  final message = ChatMessage(
    senderId: senderId,
    text: text,
    timestamp: DateTime.now(),
    readBy: {
      senderId: true, // sender has already "read" their own message
      receiverId: false,
    },
  );

  await FirebaseFirestore.instance
      .collection('trip_req')
      .doc(rideId)
      .collection('messages')
      .add(message.toMap());
}

// ---------------------------------------------------------------------------
// Batch-mark every unread message for currentUser as read
// ---------------------------------------------------------------------------
Future<void> markMessagesAsRead(String rideId, String currentUserId) async {
  final snap = await FirebaseFirestore.instance
      .collection('trip_req')
      .doc(rideId)
      .collection('messages')
      .where('readBy.$currentUserId', isEqualTo: false)
      .get();

  if (snap.docs.isEmpty) return; // nothing to update — skip the batch

  final batch = FirebaseFirestore.instance.batch();
  for (final doc in snap.docs) {
    batch.update(doc.reference, {'readBy.$currentUserId': true});
  }
  await batch.commit();
}
