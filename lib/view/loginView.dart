import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj2/constants/routes.dart';
import 'package:proj2/services/auth/auth_service.dart';
import 'package:proj2/services/auth/bloc/auth_bloc.dart';
import 'package:proj2/services/auth/bloc/auth_event.dart';
import '../services/auth/auth_exception.dart';
import 'package:proj2/utilities/dialogs/error_dialog.dart';
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  //=======================making the text editing controller ========
  late final TextEditingController _email;
  late final TextEditingController _password;

  //=============initialise the controller============================
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  //=================after one time used it is disposed of============
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

//===================basic layout of the app=====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Login page'),
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //contains the textEditors in the tools
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'enter the email address',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                    controller: _password,
                    enableSuggestions: false,
                    autocorrect: false,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'enter the password',
                    )),
              ),
              // contains the part that process and links the code to firebase remove most of the errors
              //also contains all the navigators from this page to the others
              SizedBox(
                child: TextButton(
                    onPressed: ()async  {
                      final email = _email.text;
                      final password = _password.text;

                      try {
                        context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                      }
                      on UserNotFoundAuthException{
                        await showErrorDialog(context, 'User not found');
                      }
                      on WrongPasswordAuthException{
                       await  showErrorDialog(context, 'Wrong credentials');
                      }
                      on GenericAuthException{
                      await  showErrorDialog(context, 'Authentication error');
                      }
                    },
                    child: const Text('Login')),
              ),
              //going from this page to register page using push named and remove until
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      registerRoute,
                      (route) => false,
                    );
                  },
                  child: const Text('Not registered yet? Register here!')),
            ],
          )),
    );
  }
}
