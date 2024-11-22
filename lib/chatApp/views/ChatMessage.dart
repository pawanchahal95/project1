import 'package:flutter/material.dart';
import 'package:proj2/chatApp/chat.dart';
import 'package:flutter/services.dart'; // For copying to clipboard
import 'package:share/share.dart';

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
  Future<void> _initializeData() async {
    await ChatService().open();  // Open the database
    ChatService().allChats.listen((chats) {
      // Handle chat data update
    });
    ChatService().allUsers.listen((users) {
      // Handle user data update
    });
  }

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _controller = TextEditingController();
    _initializeData();

    // Open the database when the page is opened
     // Ensure this method correctly opens the database if required
  }

  // Open the database instance and make sure it's ready
  Future<void> _openDatabase() async {
    await _chatService.open();  // Assuming the open method handles the database connection
    setState(() {}); // Force a rebuild to ensure that the UI reflects the database being ready
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute < 10 ? '0' : ''}${dateTime.minute}";
  }

  Future<void> _deleteMessage(int chatId) async {
    await _chatService.deleteChat(id: chatId); // Implement `deleteChat` in your ChatService
  }

  Future<void> _copyToClipboard(String message) async {
    await Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
  }

  Future<void> _shareMessage(String message) async {
    await Share.share(message); // Share the message text with other apps
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54), // WhatsApp green
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown, // Makes the text fit better when space is limited
                child: Text(widget.chatWith),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future:_chatService.open(),
              builder: (context,snapshot){
                return StreamBuilder<List<ChatRoom>>(
                  stream: _chatService.allNewChats, // Stream from your service
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          const Text("i am stuck"),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final chatList = snapshot.data ?? [];
                    final relevantChats = chatList.where((chat) =>
                    (chat.senderId == widget.currentUser &&
                        chat.receiverId == widget.chatWith) ||
                        (chat.senderId == widget.chatWith &&
                            chat.receiverId == widget.currentUser)).toList();

                    relevantChats.sort((a, b) => DateTime.parse(a.timestamp)
                        .compareTo(DateTime.parse(b.timestamp)));

                    return ListView.builder(
                      itemCount: relevantChats.length,
                      itemBuilder: (context, index) {
                        final chat = relevantChats[index];
                        final isSentByCurrentUser = chat.senderId == widget.currentUser;
                        final sentTime = DateTime.parse(chat.timestamp);

                        return Align(
                          alignment: isSentByCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 8.0),
                            child: GestureDetector(
                              onLongPress: () {
                                if (isSentByCurrentUser) {
                                  // Show options when long-pressed on the message bubble only if the user sent the message
                                  _showMessageOptions(context, chat);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                constraints: BoxConstraints(
                                  maxWidth: screenWidth * 0.75, // Bubble width based on screen width
                                ),
                                decoration: BoxDecoration(
                                  color: isSentByCurrentUser
                                      ? const Color(0xFFDCF8C6) // WhatsApp green for sent messages
                                      : Colors.white, // Light gray for received messages
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
                                      _formatTime(sentTime),
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
                );
              },
            ),
          ),
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
                          vertical: 10, horizontal: 15),
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
                      await _chatService.createChat(
                        message: message,
                        senderId: widget.currentUser,
                        receiverId: widget.chatWith,
                      );
                      _controller.clear();
                    }
                  },
                  child: CircleAvatar(
                    radius: screenWidth * 0.04, // Adjust the send button size based on screen height
                    backgroundColor: const Color(0xFF075E54), // WhatsApp green
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // Show options (delete, copy, share)
  void _showMessageOptions(BuildContext context, chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Message'),
              onTap: () async {
                Navigator.pop(context);
                if (chat.senderId == widget.currentUser) {
                  await _deleteMessage(chat.id); // Only if the sender is the current user
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Message'),
              onTap: () async {
                Navigator.pop(context);
                await _copyToClipboard(chat.message); // Copy message
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Message'),
              onTap: () async {
                Navigator.pop(context);
                await _shareMessage(chat.message); // Share message
              },
            ),
          ],
        );
      },
    );
  }
}
















