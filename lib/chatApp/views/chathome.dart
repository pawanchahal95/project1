import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj2/chatApp/chat.dart';
import '../../enums/menu_actions.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/bloc/auth_bloc.dart';
import '../../services/auth/bloc/auth_event.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  late final TextEditingController _controller;
  late final ChatService _chatService;
  late final String email;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _controller = TextEditingController();
    email = AuthService.firebase().currentUser!.email;
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      await _chatService.getOrCreateUser(email: email);
    } catch (e) {
      print('Error initializing user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Home Page"),
        backgroundColor: Colors.red,
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                if (shouldLogout) {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                }
                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Logout'),
              ),
            ];
          }),
        ],
      ),
      body: FutureBuilder(
        future: _chatService.getOrCreateUser(email: email),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return const Center(child: Text("No user found or created"));
              }
              return StreamBuilder<List<DatabaseUsers>>(
                stream: _chatService.allUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  final users = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user.email),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                currentUser:
                                AuthService.firebase().currentUser!.email,
                                chatWith: user.email,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            default:
              return const Center(child: Text("Something went wrong"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NewPage()),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.people),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class NewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<List<DatabaseUsers>>(
        stream: ChatService().allUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final users = snapshot.data ?? [];
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.email),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        currentUser: AuthService.firebase().currentUser!.email,
                        chatWith: user.email,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String currentUser;
  final String chatWith;

  const ChatPage({
    Key? key,
    required this.currentUser,
    required this.chatWith,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.chatWith}'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatRoom>>(
              stream: _chatService.allChats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chats = snapshot.data ?? [];
                final relevantChats = chats.where((chat) =>
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

                    return ListTile(
                      title: Text(chat.message),
                      subtitle: Text(
                        isSentByCurrentUser ? 'You' : widget.chatWith,
                      ),
                      trailing: isSentByCurrentUser
                          ? const Icon(Icons.arrow_forward)
                          : const Icon(Icons.arrow_back),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      await _chatService.createChat(
                        message: message,
                        senderId: widget.currentUser,
                        receiverId: widget.chatWith,
                      );
                      _messageController.clear();
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
