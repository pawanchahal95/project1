import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj2/main.dart';
import 'dart:developer' as developer show log;

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
              const Text('Please verify your email Address'),
              TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();
                  },
                  child: const Text('Send email verification')),
              //temporary
              TextButton(
                  onPressed: ()  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotesView()),
                    );
                  },
                  child: const Text('will verify later on'))
            ],
          ),
        ),
      ),
    );
  }
}
