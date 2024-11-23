import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj2/chatApp/cloudChat/view/ChatMessage.dart';
import 'package:proj2/services/auth/auth_service.dart';

import 'package:proj2/chatApp/cloudChat/chat.dart';
import '../../../enums/menu_actions.dart';
import '../../../services/auth/bloc/auth_bloc.dart';
import '../../../services/auth/bloc/auth_event.dart';
import '../../../utilities/dialogs/logout_dialog.dart';

class ListUser extends StatefulWidget {
  const ListUser({super.key});

  @override
  State<ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  late final TextEditingController _controller;
  late final FirebaseCloudStorage _chatService;
  late final String email;

  @override
  void initState() {
    super.initState();
    _chatService = FirebaseCloudStorage();
    _controller = TextEditingController();
    email = AuthService.firebase().currentUser!.email;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contacts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700, // WhatsApp Green
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
        future: _chatService.getUser(email: email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          return StreamBuilder<Iterable<CloudUser>>(
            stream: _chatService.allUsersList(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return Center(child: Text("Error: ${userSnapshot.error}"));
              }

              final users = userSnapshot.data ?? [];
              return StreamBuilder<List<ChatRoom>>(
                stream: _chatService.getChatRoomsStream(),
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
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                        shadowColor: Colors.black26,
                        child: GestureDetector( // Wrap the ListTile with GestureDetector
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatView(
                                  currentUser: AuthService.firebase().currentUser!.email,
                                  chatWith: user,
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey.shade300,
                              child: Icon(
                                Icons.person,
                                color: Colors.green.shade700,
                                size: 30,
                              ),
                            ),
                            title: Text(
                              user,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: const Text(
                              "Tap to chat",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chat_bubble,
                              color: Colors.green,
                            ),
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
    );
  }

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
