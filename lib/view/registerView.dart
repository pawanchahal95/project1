import 'package:flutter/material.dart';
import 'package:proj2/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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
        backgroundColor: Color.fromARGB(251, 241, 223, 233),
        appBar: AppBar(
          title: const Text(
            'register',
            style: TextStyle(color:Colors.white),
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
// ===============================the very code for the button for submitting as well as checking the errors
                              //==============for better understanding  change the order in which error are checked like the preference goes to the password
                              //over repeated email address and the highest priority is with the
                                onPressed:()async{
                                  final email=_email.text;
                                  final password=_password.text;
                                  try {
                                    final userCredential=   await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                        email: email,
                                        password: password
                                    );
                                    print(userCredential);
                                  }
                                  catch(e){
                                    String errorMessage;
                                    if(e is FirebaseAuthException){
                                      switch(e.code){
                                        case 'invalid-email':
                                          errorMessage='The email address is badly formatted.';
                                          break;
                                        case 'email-already-in-use':
                                          errorMessage= 'The email is already in use by another account.';
                                          break;
                                        case 'weak-password':
                                          errorMessage='The password is too weak. Please enter a stronger password.';
                                          break;
                                        case 'operation-not-allowed':
                                          errorMessage='Email/Password sign-in is disabled. Please enable it in the Firebase Console.';
                                          break;
                                        case 'too-many-requests':
                                          errorMessage='Too many attempts. Please wait a while before trying again.';
                                          break;
                                        case 'network-request-failed':
                                          errorMessage='Network error occurred. Please check your connection and try again.';
                                          break;
                                        default:
                                          errorMessage='Unknown error: ${e.message}';
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(errorMessage),
                                        backgroundColor: Colors.orange,
                                      ));
                                    }
                                  }
                                },
                                child: Text('Register')),
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