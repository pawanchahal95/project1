import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj2/chatApp/chat.dart';
import 'package:proj2/chatApp/views/ChatMessage.dart';
import 'package:proj2/services/auth/auth_service.dart';
import '../../enums/menu_actions.dart';
import '../../services/auth/bloc/auth_bloc.dart';
import '../../services/auth/bloc/auth_event.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class ListUser extends StatefulWidget {
  const ListUser({super.key});

  @override
  State<ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
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
        title: const Text(
          "Lots of Other Users",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green, // WhatsApp Green
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeUser(), // Avoid redundant calls
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          return StreamBuilder<List<DatabaseUsers>>(
            stream: _chatService.allNewUsers,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return Center(child: Text("Error: ${userSnapshot.error}"));
              }

              final users = userSnapshot.data ?? [];
              return StreamBuilder<List<ChatRoom>>(
                stream: _chatService.allNewChatsList,
                builder: (context, chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (chatSnapshot.hasError) {
                    return Center(child: Text("Error: ${chatSnapshot.error}"));
                  }

                  final chatList = chatSnapshot.data ?? [];
                  final relevantChats = chatList.where((chat) =>
                  chat.senderId == email || chat.receiverId == email).toList();

                  final Set<String> uniqueUsers = {
                    for (final user in users) user.email
                  };

                  for (final chat in relevantChats) {
                    if (chat.senderId == email) {
                      uniqueUsers.remove(chat.receiverId);
                    } else {
                      uniqueUsers.remove(chat.senderId);
                    }
                  }

                  if (uniqueUsers.isEmpty) {
                    return const Center(child: Text("No users available to chat"));
                  }

                  return ListView.builder(
                    itemCount: uniqueUsers.length,
                    itemBuilder: (context, index) {
                      final user = uniqueUsers.elementAt(index);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          title: Text(
                            user,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.chat_bubble,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatView(
                                    currentUser: AuthService.firebase()
                                        .currentUser!
                                        .email,
                                    chatWith: user,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add relevant functionality here
        },
        backgroundColor: Colors.green, // WhatsApp Green
        child: const Icon(Icons.people),
      ),
    );
  }


  // Function to show the dialog or navigate to the edit username screen
  void _showUserDialog(String userEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Username"),
          content: TextField(
            controller: TextEditingController(text: userEmail),
            decoration: const InputDecoration(labelText: 'Enter new username'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Handle saving the new username here
                // You can update the username by calling a function from your ChatService or AuthService
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
