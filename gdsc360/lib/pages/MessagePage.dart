import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:gdsc360/components/SpeechButton.dart'; // Ensure this is correctly implemented
import 'package:gdsc360/utils/authservice.dart'; // Your custom Auth service
import 'package:gdsc360/utils/chatservice.dart'; // Your custom Chat service

class MessagePage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const MessagePage(
      {super.key,
      required this.receiverUserID,
      required this.receiverUserEmail});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final Auth _auth = Auth();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to work with the Future returned by getUserData
    return FutureBuilder<Map<String, dynamic>?>(
      future: _auth.getUserData(
          widget.receiverUserID), // The Future that you are waiting for
      builder: (context, snapshot) {
        // Check the connection state of the Future
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator while waiting for the Future to complete
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // If the Future completes with an error, return an error widget
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text("Error loading user data")),
          );
        } else if (snapshot.hasData) {
          // If the Future completes with data, use the data to build your widget
          var receiverData =
              snapshot.data!; // Now you have your Map<String, dynamic>
          return Scaffold(
            appBar: AppBar(
              title: Text(receiverData["name"] ?? "User"),
              automaticallyImplyLeading: false, // Use the data as needed
            ),
            body: Column(
              children: [
                Expanded(
                  child: _buildMessageList(),
                ),
                _buildMessageInput(),
              ],
            ),
          );
        } else {
          // Handle the case where you have no data
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text("No user data available")),
          );
        }
      },
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
          widget.receiverUserID, _auth.getCurrentUserUid().toString()),
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

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send,
                color: Colors.blue), // Adjusted icon color for visibility
            onPressed: () {
              sendMessage();
            },
          ),
        ],
      ),
    );
  }
}
