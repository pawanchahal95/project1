import 'package:flutter/material.dart';
import 'package:proj2/constants/routes.dart';
import 'package:proj2/services/auth/auth_service.dart';
import 'package:proj2/utilities/showErrorDialog.dart';
import 'package:proj2/services/auth/auth_exception.dart';

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
                        await AuthService.firebase().createUser(
                          email: email,
                          password: password,
                        );
                        final user = AuthService.firebase().currentUser;
                      await  AuthService.firebase().sendEmailVerification();
                        Navigator.of(context).pushNamed(
                          verifyEmailRoute,
                        );
                      } on WeakPasswordAuthException {
                        await ShowErrorDialog(context, 'Weak password');
                      } on EmailAlreadyInUseAuthException {
                        await ShowErrorDialog(context, 'Email already in use');
                      } on InvalidEmailAuthException {
                        await ShowErrorDialog(context, 'Invalid email');
                      } on GenericAuthException {
                        await ShowErrorDialog(context, 'Authentication error');
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
