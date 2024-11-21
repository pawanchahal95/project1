import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj2/constants/routes.dart';
import 'package:proj2/main.dart';
import 'package:proj2/services/auth/auth_service.dart';
import 'package:proj2/services/auth/bloc/auth_bloc.dart';
import 'package:proj2/services/auth/bloc/auth_event.dart';


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
              const Text(
                  "We've sent you an email verification.Please open it to verify your account."),
              const Text(
                  "If you haven't received a verification email yet, press the button below"),
              TextButton(
                  onPressed: () async {
                    context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
                  },
                  child: const Text('Send email verification')),
              //temporary
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text('Go BACK'))
            ],
          ),
        ),
      ),
    );
  }
}
