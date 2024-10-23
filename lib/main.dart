import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj2/view/VerifyEmailView.dart';
import 'constants/routes.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proj2/view/loginView.dart';
import 'package:proj2/view/registerView.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.lightBlue,
    ),
    home: HomePage(),
    routes: {
      loginRoute: (context) => LoginView(),
      registerRoute: (context) => RegisterVIew(),
      notesRoute: (context) => NotesView(),

    },
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (user.emailVerified) {
                  return NotesView();
                } else {
                  return VerifyEmailView();
                }
              } else {
                return LoginView();
              }
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

enum MenuAction { logout }

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
        title: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text('Main UI'),
          ),
        ),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value)async {
             switch(value){
               case MenuAction.logout:
                 final shouldLogout=await ShowLogOutDialog(context);
                 if(shouldLogout){
                   await FirebaseAuth.instance.signOut();
                   Navigator.of(context).pushNamedAndRemoveUntil('/login/',(route)=>false);
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
      body: Center(
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Radhika is a genius but not greater than me',style: TextStyle(fontSize: 50),),
            const Text('or is that true'),
          ],
        ),
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
            TextButton(onPressed: () {
              Navigator.of(context).pop(false);
            }, child: const Text('Cancel')),
            TextButton(onPressed: () {
              Navigator.of(context).pop(true);
            }, child: const Text('Log Out')),
          ],
        );
      }).then((value)=>value??false);
}
