import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proj2/firebase_options.dart';



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
    _email=TextEditingController();
    _password=TextEditingController();
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.redAccent,
        appBar: AppBar(
          title: const Text(
            'Login',
            style: TextStyle(color:Colors.black),
          ),
          backgroundColor: Colors.redAccent,
          centerTitle: true,
        ),
        body:  FutureBuilder(
            future: Firebase.initializeApp(
              options:DefaultFirebaseOptions.currentPlatform,
            ),
            builder: (context,snapshot){
              switch(snapshot.connectionState) {
              /* case ConnectionState.none:
                  // TODO: Handle this case.
                case ConnectionState.waiting:
                  // TODO: Handle this case.
                case ConnectionState.active:
                  // TODO: Handle this case.*/
                case ConnectionState.done:
                  return Padding(padding:EdgeInsets.all(16.0),

                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextField(
                                controller: _email,
                                enableSuggestions: false,
                                autocorrect:  false,
                                keyboardType: TextInputType.emailAddress,
                                decoration:InputDecoration(
                                  hintText:'enter the email address',

                                )
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                                controller: _password,
                                enableSuggestions: false,
                                autocorrect:  false,
                                obscureText: true,
                                decoration:InputDecoration(
                                  hintText:'enter the password',
                                )
                            ),
                          ),
                          SizedBox(
                            child: TextButton(

                                /*onPressed:()async{
                                  final email=_email.text;
                                  final password=_password.text;
                                  try {
                                    final userCredential = await FirebaseAuth
                                        .instance.signInWithEmailAndPassword(
                                        email: email,
                                        password: password
                                    );
                                    print(userCredential);
                                  }
                                  on FirebaseAuthException catch(e){
                                    if(e.code == 'user-not-found'){
                                      print('user is not available');
                                    }
                                  }
                                },*/
                                onPressed: () async {
                                  final email = _email.text;
                                  final password = _password.text;

                                  try {
                                    // Firebase sign-in code
                                    UserCredential userCredential = await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(email: email, password: password);

                                    print('Login successful: $userCredential');
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
                                          errorMessage = 'The supplied auth credential is malformed or has expired.';
                                          break;
                                        default:
                                          errorMessage = 'Unknown error: ${e.message}';
                                      }
                                      // Show error message to the user
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(errorMessage),
                                        backgroundColor: Colors.orange,
                                      ));
                                    } else {
                                      // General error handling
                                      print('An error occurred: $e');
                                    }
                                  }
                                },

                                child: Text('Login')),
                          ),

                        ],
                      )
                  );
                default:
                  return const Text('Loading .............');
              }
            }
        ),

      ),
    );
  }
}


