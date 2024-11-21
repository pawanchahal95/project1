import 'package:flutter/material.dart';
import 'package:proj2/chatApp/chat.dart';

class ChatVeiw extends StatefulWidget {
  final String currentUser;
  final String chatWith;

  const ChatVeiw(
      {super.key, required this.currentUser, required this.chatWith});

  @override
  State<ChatVeiw> createState() => _ChatVeiwState();
}

class _ChatVeiwState extends State<ChatVeiw> {
  late final ChatService _chatService;
  late final TextEditingController _controller;

  @override
  void initState() {
    _chatService = ChatService();
    _controller=TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.chatWith}"),
        backgroundColor: Colors.greenAccent,
      ),
      body: Column(
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
                        final chat=relevantChats.elementAt(index);
                        final isSentByCurrentUser =
                            chat.senderId == widget.currentUser;
                        return ListTile(
                            title:Text(chat.message),
                          subtitle: Text(
                            isSentByCurrentUser ? 'You' : widget.chatWith,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: isSentByCurrentUser
                              ? const Icon(Icons.arrow_forward)
                              : const Icon(Icons.arrow_back),
                        );
                      })
                  ;
                }),
          ),
          Padding
            (
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
    );
  }
}
