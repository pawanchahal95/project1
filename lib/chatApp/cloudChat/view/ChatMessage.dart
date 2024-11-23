import 'package:flutter/material.dart';
import 'package:proj2/chatApp/cloudChat/chat.dart';
import 'package:flutter/services.dart'; // For clipboard operations

class ChatView extends StatefulWidget {
  final String currentUser;
  final String chatWith;

  const ChatView({
    super.key,
    required this.currentUser,
    required this.chatWith,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final FirebaseCloudStorage _chatService;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _chatService = FirebaseCloudStorage();
    _controller = TextEditingController();
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final user = _chatService.getUser(email: widget.chatWith);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54), // WhatsApp green
        title: FutureBuilder<CloudUser>(
          future: _chatService.getUser(email: widget.chatWith),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a placeholder with a loading state
              return const Row(

                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey, // Placeholder color
                    radius: 20, // Same size as actual image
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Loading...",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              // Handle errors or no data with fallback UI
              return const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey, // Placeholder color
                    radius: 20,
                    child: Icon(Icons.error, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "User not found",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              );
            }

            // If data is available, show the user's details
            final user = snapshot.data!;
            return Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(user.userImage),
                  // Replace with actual data
                  backgroundColor:
                      Colors.grey.shade300, // Fallback background color
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    user.userName,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: StreamBuilder<List<ChatRoom>>(
              stream: _chatService.getChatRoomsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final chatRooms = snapshot.data ?? [];
                final relevantChats = chatRooms
                    .where((chat) =>
                        (chat.senderId == widget.currentUser &&
                            chat.receiverId == widget.chatWith) ||
                        (chat.senderId == widget.chatWith &&
                            chat.receiverId == widget.currentUser))
                    .toList();

                relevantChats
                    .sort((a, b) => a.timestamp.compareTo(b.timestamp));

                return ListView.builder(
                  itemCount: relevantChats.length,
                  itemBuilder: (context, index) {
                    final chat = relevantChats[index];
                    final isSentByCurrentUser =
                        chat.senderId == widget.currentUser;

                    return Align(
                      alignment: isSentByCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 8.0,
                        ),
                        child: GestureDetector(
                          onLongPress: () {
                            // Add options like copy or share
                            Clipboard.setData(
                                ClipboardData(text: chat.message));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Message copied")),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isSentByCurrentUser
                                  ? const Color(0xFFDCF8C6) // WhatsApp green
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(10),
                                topRight: const Radius.circular(10),
                                bottomLeft: isSentByCurrentUser
                                    ? const Radius.circular(10)
                                    : Radius.zero,
                                bottomRight: isSentByCurrentUser
                                    ? Radius.zero
                                    : const Radius.circular(10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isSentByCurrentUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chat.message,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _formatTime(chat.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message input area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      await _chatService.sendMessage(
                        message: message,
                        senderId: widget.currentUser,
                        receiverId: widget.chatWith,
                      );
                      _controller.clear();
                    }
                  },
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF075E54),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
