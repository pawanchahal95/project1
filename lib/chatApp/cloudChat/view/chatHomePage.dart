import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj2/chatApp/cloudChat/chat.dart';
import 'package:proj2/chatApp/cloudChat/view/ChatMessage.dart';
import 'package:proj2/chatApp/cloudChat/view/listUsers.dart';
import 'package:proj2/enums/menu_actions.dart';
import 'package:proj2/services/auth/auth_service.dart';
import 'package:proj2/utilities/dialogs/logout_dialog.dart';
import '../../../services/auth/bloc/auth_bloc.dart';
import '../../../services/auth/bloc/auth_event.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  late final FirebaseCloudStorage _cloudStorage;
  late final String email;

  @override
  void initState() {
    super.initState();
    _cloudStorage = FirebaseCloudStorage();
    email = AuthService.firebase().currentUser!.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "WhatsApp",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF075E54),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Placeholder for search functionality
            },
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              if (value == MenuAction.logout) {
                final shouldLogout = await showLogOutDialog(context);
                if (shouldLogout) {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, child: Text('Logout')),
            ],
          ),

        ],
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: _cloudStorage.getChatRoomsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final chats = snapshot.data ?? [];

          // Fetch users based on chat participants
          return FutureBuilder<Iterable<CloudUser>>(
            future: _cloudStorage.getAllUsers(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return Center(child: Text("Error: ${userSnapshot.error}"));
              }

              final users = userSnapshot.data ?? [];
              final uniqueUsers = <String>{};

              // Filter chat participants
              for (final chat in chats) {
                if (chat.senderId == email) {
                  uniqueUsers.add(chat.receiverId);
                } else {
                  uniqueUsers.add(chat.senderId);
                }
              }

              if (uniqueUsers.isEmpty) {
                return const Center(child: Text("No chats found"));
              }

              return ListView.builder(
                itemCount: uniqueUsers.length,
                itemBuilder: (context, index) {
                  final chatPartner = uniqueUsers.elementAt(index);

                  // Find user details from the list of users
                  final user = users.firstWhere(
                        (user) => user.email == chatPartner,
                    orElse: () => CloudUser(
                      documentId: '',
                      email: '',
                      userDialog: 'No dialog',
                      userImage: 'https://placekitten.com/200/200', // Placeholder
                      userName: chatPartner,
                      userId: chatPartner,
                    ),
                  );

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(user.userImage),
                      backgroundColor: Colors.grey.shade300,
                    ),
                    title: Text(
                      user.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      user.userDialog,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Text(
                      "12:34 PM", // Placeholder for timestamp
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatView(
                            currentUser: email,
                            chatWith: chatPartner,
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListUser()));
        },
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.message),
      ),
    );
  }
}
