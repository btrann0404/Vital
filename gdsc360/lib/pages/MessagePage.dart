import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:gdsc360/components/SpeechButton.dart'; // Ensure this is correctly implemented
import 'package:gdsc360/utils/authservice.dart'; // Your custom Auth service
import 'package:gdsc360/utils/chatservice.dart'; // Your custom Chat service

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final Auth _auth = Auth();
  late Future<Map<String, dynamic>?> partnerDataFuture;

  @override
  void initState() {
    super.initState();
    partnerDataFuture = _fetchPartnerData();
  }

  Future<Map<String, dynamic>?> _fetchPartnerData() async {
    String currUserID = _auth.getCurrentUserUid().toString();
    Map<String, dynamic>? currentUserInfo = await _auth.getUserData(currUserID);
    String partnerID = currentUserInfo?["partnerID"];
    return await _auth.getUserData(partnerID);
  }

  void sendMessage(String receiverUserID) async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: partnerDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              appBar: AppBar(),
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text("Error loading partner data")));
        } else if (snapshot.hasData) {
          var partnerData = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(partnerData["name"] ?? "Partner"),
              automaticallyImplyLeading: false,
            ),
            body: Column(
              children: [
                Expanded(
                  child: _buildMessageList(partnerData["userID"]),
                ),
                _buildMessageInput(partnerData["userID"]),
              ],
            ),
          );
        } else {
          return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text("No partner data available")));
        }
      },
    );
  }

  Widget _buildMessageList(String receiverUserID) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
          receiverUserID, _auth.getCurrentUserUid().toString()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(documents[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    var alignment = (data["senderID"] == _auth.getCurrentUserUid())
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: (alignment == Alignment.centerRight)
              ? Colors.blue[100]
              : Colors.grey[300],
        ),
        child: Column(
          crossAxisAlignment: (alignment == Alignment.centerRight)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(data["senderEmail"],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(data["message"], style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(String receiverUserID) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () => sendMessage(receiverUserID),
          ),
        ],
      ),
    );
  }
}
