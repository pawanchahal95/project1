import 'package:flutter/material.dart';
import 'package:proj2/constants/routes.dart';
import 'package:proj2/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as developer show log;

import 'package:proj2/utilities/showErrorDialog.dart';

class RegisterVIew extends StatefulWidget {
  RegisterVIew({super.key});

  @override
  State<RegisterVIew> createState() => _RegisterVIewState();
}

class _RegisterVIewState extends State<RegisterVIew> {
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
            child: const Text('Register page'),
          ),
        ),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              //contains the basic textEditors
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
              //contains the part that process and links the code to firebase remove most of the errors
              //also contains all the navigators from this page to the others
              SizedBox(
                child: TextButton(
                    // ===============================the very code for the button for submitting as well as checking the errors
                    //==============for better understanding  change the order in which error are checked like the preference goes to the password
                    //over repeated email address and the highest priority is with the
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      try {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        final user=FirebaseAuth.instance.currentUser;
                        user?.sendEmailVerification();
                        Navigator.of(context).pushNamed(
                          verifyEmailRoute,
                        );
                      } catch (e) {
                        String errorMessage;
                        if (e is FirebaseAuthException) {
                          switch (e.code) {
                            case 'invalid-email':
                              errorMessage =
                                  'The email address is badly formatted.';
                              break;
                            case 'email-already-in-use':
                              errorMessage =
                                  'The email is already in use by another account.';
                              break;
                            case 'weak-password':
                              errorMessage =
                                  'The password is too weak. Please enter a stronger password.';
                              break;
                            default:
                              errorMessage = 'Unknown error: ${e.message}';
                          }
                          ShowErrorDialog(context, errorMessage);
                        }
                        else{

                      ShowErrorDialog(context, e.toString());


                        }
                      }
                    },
                    child: Text('Register')),
              ),
              //going to login page by removing the register page from the app completely from the memory
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  },
                  child: Text('Already registered ? login here!')),
            ],
          )),
    );
  }
}
