import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj2/constants/routes.dart';
import 'package:proj2/main.dart';
import 'dart:developer' as developer show log;

import 'package:proj2/view/registerView.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text('Verify page'),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text("We've sent you an email verification.Please open it to verify your account."),
              const Text("If you haven't received a verification email yet, press the button below"),
              TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();
                  },
                  child: const Text('Send email verification')),
              //temporary
              TextButton(
                  onPressed: ()  {
                   Navigator.of(context).pushNamedAndRemoveUntil(registerRoute,(route)=>false);
                  },
                  child: const Text('Go BACK'))
            ],

          ),
        ),
      ),
    );
  }
}
