import 'package:flutter/material.dart';
import 'package:proj2/chatApp/chat.dart';
class ChatView extends StatefulWidget {
  final String currentUser;
  final String chatWith;

  const ChatView({super.key, required this.currentUser, required this.chatWith});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final ChatService _chatService;
  late final TextEditingController _controller;

  @override
  void initState() {
    _chatService = ChatService();
    _controller = TextEditingController();
    super.initState();
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute < 10 ? '0' : ''}${dateTime.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.chatWith}"),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Padding around the whole screen
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: _chatService.allChats,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text("this is causing error ${snapshot.error}");
                    }
                    final chatList = snapshot.data ?? [];
                    final relevantChats = chatList.where((chat) =>
                    (chat.senderId == widget.currentUser &&
                        chat.receiverId == widget.chatWith) ||
                        (chat.senderId == widget.chatWith &&
                            chat.receiverId == widget.currentUser));
                    return ListView.builder(
                        itemCount: relevantChats.length,
                        itemBuilder: (context, index) {
                          final chat = relevantChats.elementAt(index);
                          final isSentByCurrentUser =
                              chat.senderId == widget.currentUser;
                          final sentTime = DateTime.parse(chat.timestamp); // Assuming timestamp is stored in the chat

                          return Align(
                            alignment: isSentByCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Column(
                                crossAxisAlignment: isSentByCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.7, // Adjust max width
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSentByCurrentUser
                                          ? Colors.greenAccent
                                          : Colors.blueGrey,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      chat.message,
                                      style: TextStyle(color: Colors.white),
                                      softWrap: true, // Allow wrapping of long text
                                      overflow: TextOverflow.visible, // Ensure text does not get cut off
                                    ),
                                  ),
                                  // Timestamp outside the message container, below it
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      _formatTime(sentTime),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.red),
                    onPressed: () async {
                      final message = _controller.text.trim();
                      if (message.isNotEmpty) {
                        await _chatService.createChat(
                          message: message,
                          senderId: widget.currentUser,
                          receiverId: widget.chatWith,
                        );
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}