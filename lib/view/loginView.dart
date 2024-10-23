import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proj2/constants/routes.dart';
import 'package:proj2/firebase_options.dart';
import 'dart:developer' as developer show log;

import '../utilities/showErrorDialog.dart';

class LoginView extends StatefulWidget {
  LoginView({super.key});

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
        title: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text('Login page'),
          ),
        ),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
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
                    decoration: InputDecoration(
                      hintText: 'enter the password',
                    )),
              ),
              SizedBox(
                child: TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;

                      try {
                        // Firebase sign-in code
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithEmailAndPassword(
                                email: email, password: password);
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoute,
                          (route) => false,
                        );
                      } catch (e) {
                        if (e is FirebaseAuthException) {
                          String errorMessage;
                          // Handling specific FirebaseAuth errors
                          switch (e.code) {
                            case 'invalid-email':
                              errorMessage = 'The email address is badly formatted.';
                              break;
                            case 'user-not-found':
                              errorMessage = 'No user found with this email.';
                              break;
                            case 'wrong-password':
                              errorMessage = 'The password is invalid.';
                              break;
                            case 'invalid-credential':
                              errorMessage =
                                  'The supplied auth credential is malformed or has expired.';
                              break;
                            default:
                              errorMessage = 'Unknown error: ${e.message}';
                          }
                         ShowErrorDialog(context, errorMessage);
                        } else {
                          // General error handling
                          ShowErrorDialog(context,e.toString());
                        }
                      }
                    },
                    child: Text('Login')),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      registerRoute,
                      (route) => false,
                    );
                  },
                  child: Text('Not registered yet? Register here!')),
            ],
          )),
    );
  }
}


