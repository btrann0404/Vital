import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdsc360/model/message.dart';
import 'package:gdsc360/utils/authservice.dart';

class ChatService extends ChangeNotifier {
  final Auth _auth = Auth();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverID, String message) async {
    String? currUid = _auth.getCurrentUserUid();
    if (currUid == null) {
      throw Exception("Current user ID is null");
    }

    // Await the Future to complete and get the user data
    Map<String, dynamic>? currentUserInfo = await _auth.getUserData(currUid);

    if (currentUserInfo == null) {
      throw Exception("Current user info is null");
    }

    Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currUid,
      senderEmail: currentUserInfo[
          'email'], // Assuming 'email' exists in the user data map
      receiverID: receiverID,
      timestamp: timestamp,
      message: message,
    );

    List<String> ids = [currUid, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    await _fireStore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot<Object?>> getMessages(
      String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _fireStore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection('messages')
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
