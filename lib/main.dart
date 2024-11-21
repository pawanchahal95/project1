import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj2/chatApp/views/chathome.dart';
import 'package:proj2/services/auth/bloc/auth_bloc.dart';
import 'package:proj2/services/auth/bloc/auth_event.dart';
import 'package:proj2/services/auth/bloc/auth_state.dart';
import 'package:proj2/services/auth/firebase_auth_provider.dart';
import 'package:proj2/view/VerifyEmailView.dart';
import 'chatApp/views/ChatHomePage.dart';
import 'constants/routes.dart';
import 'package:proj2/view/loginView.dart';
import 'package:proj2/view/registerView.dart';
import 'package:proj2/view/notes/create_update_notes_view.dart';
import 'package:proj2/view/notes/notesView.dart';

void main()  {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(

    debugShowCheckedModeBanner: false,
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.lightBlue,
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
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
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocBuilder<AuthBloc,AuthState>(builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        //temporary changes
       // return const NotesView();
        return const ChatHomePage();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      }
      else if(state is AuthStateRegistering){
        return const RegisterView();
      }
      else if(state is AuthStateUninitialized) {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
      else{
        return Text("something went wrong");
      }
    });
  }
}
