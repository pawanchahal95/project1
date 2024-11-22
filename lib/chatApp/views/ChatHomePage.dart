import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj2/chatApp/chat.dart';
import 'package:proj2/chatApp/views/ChatMessage.dart';
import 'package:proj2/services/auth/auth_service.dart';
import 'package:sqflite/sqflite.dart';
import '../../constants/routes.dart';
import '../../enums/menu_actions.dart';
import '../../services/auth/bloc/auth_bloc.dart';
import '../../services/auth/bloc/auth_event.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  late final ChatService _chatService;
  late final String email;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
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
        title: const Text("WhatsApp",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        actions: [
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

              return StreamBuilder<List<ChatRoom>>(
                stream: _chatService.allChats,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  final chats = snapshot.data ?? [];
                  final relevantChats = chats
                      .where((chat) =>
                          chat.senderId == email || chat.receiverId == email)
                      .toList();

                  // Filter unique chat users
                  final Set<String> uniqueUsers = {};
                  for (final chat in relevantChats) {
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

                      return ListTile(
                        title: Text(chatPartner),
                        subtitle: const Text("Last message..."),
                        // Placeholder for actual last message
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatView(
                                    currentUser: AuthService
                                        .firebase()
                                        .currentUser!
                                        .email,
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


            default:
              return Text("messed up");
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(ListUserRoute);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.people),
      ),
    );
  }
}
