import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proj2/chatApp/cloudChat/constants.dart';

class CouldNotGetUsersException implements Exception {}

@immutable
class CloudUser {
  final String documentId;
  final String email;
  final String userDialog;
  final String userImage;
  final String userName;
  final String userId;

  const CloudUser({
    required this.documentId,
    required this.email,
    required this.userDialog,
    required this.userImage,
    required this.userName,
    required this.userId,
  });

  CloudUser.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        email = snapshot.data()[emailField],
        userDialog = snapshot.data()[userDialogField],
        userId = snapshot.data()[userIdField],
        userImage = snapshot.data()[userImageField],
        userName = snapshot.data()[userNameField];
}

@immutable
class ChatRoom {
  final String id;
  final String message;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;

  const ChatRoom({
    required this.id,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  ChatRoom.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        message = snapshot.data()[messageField] ?? '',
        senderId = snapshot.data()[senderIdField] ?? '',
        receiverId = snapshot.data()[receiverIdField] ?? '',
        timestamp = (snapshot.data()[timestampField] is Timestamp)
            ? (snapshot.data()[timestampField] as Timestamp).toDate()
            : DateTime.now(); // Fallback to current date if not a Timestamp
}

class FirebaseCloudStorage {
  final users = FirebaseFirestore.instance.collection('usersList');
  final chatroom = FirebaseFirestore.instance.collection('ChatRoom');

  // ====================== Users Logic ======================
  Future<CloudUser> createNewUser({
    required String emailId,
    required String username,
    required String userDialog,
    required String userId,
    required String userImage,
  })
  async {
    try {
      final existingUsers =
      await users.where(emailField, isEqualTo: emailId).limit(1).get();

      if (existingUsers.docs.isNotEmpty) {
        final existingUserSnapshot = existingUsers.docs.first;
        return CloudUser.fromSnapshot(existingUserSnapshot);
      }

      final document = await users.add({
        userIdField: userId,
        emailField: emailId,
        userNameField: username,
        userDialogField: userDialog,
        userImageField: userImage,
      });
      final fetchedUser = await document.get();
      return CloudUser.fromSnapshot(
          fetchedUser as QueryDocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      throw Exception('Could not create user: $e');
    }
  }

  Future<CloudUser> getUser({required String email}) async {
    try {
      // Query Firestore and directly fetch the only document
      final querySnapshot = await users.where(emailField, isEqualTo: email).get();

      // Directly return the CloudUser from the single document
      return CloudUser.fromSnapshot(querySnapshot.docs.first);
    } catch (e) {
      throw CouldNotGetUsersException(); // Handle query errors
    }
  }
  Future<Iterable<CloudUser>> getAllUsers() async {
    try {
      final querySnapshot = await users.get();
      return querySnapshot.docs.map((doc) => CloudUser.fromSnapshot(doc));
    } catch (e) {
      throw CouldNotGetUsersException();
    }
  }

  Future<void> updateUserDetailsByEmail({
    required String email,
    String? userDialog,
    String? userImage,
    String? userName,
  })
  async {
    final updates = <String, dynamic>{};

    if (userDialog != null) updates[userDialogField] = userDialog;
    if (userImage != null) updates[userImageField] = userImage;
    if (userName != null) updates[userNameField] = userName;

    try {
      final querySnapshot =
      await users.where(emailField, isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No user found with the email: $email');
      }

      final document = querySnapshot.docs.first;
      await users.doc(document.id).update(updates);
    } catch (e) {
      throw Exception('Could not update user: $e');
    }
  }

  Future<void> deleteUserByEmail({required String email}) async {
    try {
      final querySnapshot =
      await users.where(emailField, isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No user found with the email: $email');
      }

      final documentId = querySnapshot.docs.first.id;
      await users.doc(documentId).delete();
    } catch (e) {
      throw Exception('Could not delete user: $e');
    }
  }

  Stream<Iterable<CloudUser>> allUsersList() => users
      .snapshots()
      .map((event) => event.docs.map((doc) => CloudUser.fromSnapshot(doc)));

  // =================== ChatRoom Logic ===================
  Future<ChatRoom> sendMessage({
    required String message,
    required String senderId,
    required String receiverId,
  })
  async {
    try {
      final document = await chatroom.add({
        messageField: message,
        senderIdField: senderId,
        receiverIdField: receiverId,
        timestampField: FieldValue.serverTimestamp(),
      });

      final fetchedMessage = await document.get();
      return ChatRoom.fromSnapshot(fetchedMessage as QueryDocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      throw Exception('Could not send message: $e');
    }
  }

  Stream<List<ChatRoom>> getChatRoomsStream() {
    return chatroom
        .snapshots()
        .map((event) => event.docs.map((doc) => ChatRoom.fromSnapshot(doc)).toList());
  }

  Future<List<ChatRoom>> getChatRooms({
    required String senderId,
    required String receiverId,
  })
  async {
    try {
      final querySnapshot = await chatroom
          .where(senderIdField, isEqualTo: senderId)
          .where(receiverIdField, isEqualTo: receiverId)
          .orderBy(timestampField, descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatRoom.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Could not fetch chat rooms: $e');
    }
  }

  Future<void> deleteChatRoom({required String chatRoomId}) async {
    try {
      await chatroom.doc(chatRoomId).delete();
    } catch (e) {
      throw Exception('Could not delete chat room: $e');
    }
  }
}
