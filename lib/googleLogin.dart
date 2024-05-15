import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

// Future<void> main() async => {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,),
//   runApp(MyApp())
// };

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseAuth.instance.useAppLanguage();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign In Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserCredential?> _handleSignIn() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication? googleSignInAuthentication =
      await googleSignInAccount?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication?.accessToken,
        idToken: googleSignInAuthentication?.idToken,
      );

      UserCredential authResult =
      await _auth.signInWithCredential(credential);
      return authResult;
    } catch (error) {
      print(error);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign In Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            UserCredential? userCredential = await _handleSignIn();
            if (userCredential != null) {
              // Navigate to next screen or do something with user data
              print("User signed in: ${userCredential.user?.displayName}");
            } else {
              // Show error message or handle sign in failure
              print("Sign in failed!");
            }
          },
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}
