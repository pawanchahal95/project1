import 'package:flutter/material.dart';
import 'package:proj2/services/auth/auth_service.dart';
import 'package:proj2/view/VerifyEmailView.dart';
import 'constants/routes.dart';
import 'package:proj2/view/loginView.dart';
import 'package:proj2/view/registerView.dart';

/*import 'package:proj2/view/notes/new_notes_view.dart';
import 'package:proj2/view/notes/notesView.dart';*/

//temporary imports
import 'temporaryfiles/noteView.dart';
import 'temporaryfiles/newnote.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.lightBlue,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => LoginView(),
      registerRoute: (context) => RegisterVIew(),
      verifyEmailRoute: (context) =>const VerifyEmailView(),
      //original routes

      notesRoute: (context) => const NotesView(),
      newNoteRoute: (context) => const NewNoteView(),






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
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user =AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
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
