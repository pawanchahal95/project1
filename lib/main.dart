import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proj2/view/loginView.dart';
import 'package:proj2/view/registerView.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.redAccent
      ),
      home: HomePage(),
    )
  );
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text('Home page'),
          ),
        ),
      ),
      body: FutureBuilder(
          future:Firebase.initializeApp(
           options:DefaultFirebaseOptions.currentPlatform,
      ),
          builder: (context,snapshot){
            switch(snapshot.connectionState){

              /*case ConnectionState.none:
                // TODO: Handle this case.
              case ConnectionState.waiting:
                // TODO: Handle this case.
              case ConnectionState.active:
                // TODO: Handle this case.*/
              case ConnectionState.done:
                final user=FirebaseAuth.instance.currentUser;
                if(user?.emailVerified ?? false){
                  print('your email is verified');
                }
                else{
                  print('need to verify email id first');
                }
                return const Text('Done');

              default:
                return const Text('loading.......');
            }
          }),
    );
  }
}




