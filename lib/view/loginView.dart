import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj2/constants/routes.dart';
import 'package:proj2/services/auth/bloc/auth_bloc.dart';
import 'package:proj2/services/auth/bloc/auth_event.dart';
import 'package:proj2/services/auth/bloc/auth_state.dart';
import 'package:proj2/utilities/dialogs/loading_dialog.dart';
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
  CloseDialog? _closeDialogHandle;

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
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateLoggedOut) {
            final closeDialog = _closeDialogHandle;
            if (!state.isLoading && closeDialog != null) {
              closeDialog();
              _closeDialogHandle = null;
            } else if (state.isLoading && closeDialog == null) {
              _closeDialogHandle = showLoadingDialog(
                context: context,
                text: 'Loading',
              );
            }
            if (state.exception is UserNotFoundAuthException) {
              await showErrorDialog(context, 'User not found');
            } else if (state.exception is WrongPasswordAuthException) {
              await showErrorDialog(context, 'Wrong credentials');
            } else if (state.exception is GenericAuthException) {
              await showErrorDialog(context, 'Authentication error');
            }
          }
        },
        child: Scaffold(
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
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          context.read<AuthBloc>().add(
                            AuthEventLogIn(
                              email,
                              password,
                            ),
                          );
                        },
                        child: const Text('Login')),
                  ),

                  //going from this page to register page using push named and remove until
                  TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          const AuthEventShouldRegister(),
                        );
                      },
                      child: const Text('Not registered yet? Register here!')),
                ],
              )),
        ));
  }
}