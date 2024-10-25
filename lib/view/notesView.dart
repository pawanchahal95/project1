import 'package:flutter/material.dart';
import 'package:proj2/constants/routes.dart';
import 'package:proj2/enums/menu_actions.dart';
import 'package:proj2/services/auth/auth_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Main UI'),
          ),
        ),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await ShowLogOutDialog(context);
                if (shouldLogout) {
                  AuthService.firebase().logOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                }
                break;
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Logout'),
              ),
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Logout2 just in case'),
              ),
            ];
          })
        ],
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'This  is  sample only',
            style: TextStyle(fontSize: 50),
          ),
          Text('not fully developed yet'),
        ],
      ),
    );
  }
}

Future<bool> ShowLogOutDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Log Out')),
          ],
        );
      }).then((value) => value ?? false);
}
