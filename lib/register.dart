import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registrationsuccessful.dart'; // Assuming this file is in the same directory

void main() {
  runApp(RegisterPage());
}

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Grocery',
      home: RegisterScreen(title: 'smartGrocery',),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key, required String title}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> registerUsingEmailPassword(
      {required String email,
        required String password,
        required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      UserCredential userCredential =
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await db.collection("Users").doc(user.uid).set({
          "name": _nameController.text,
          "email": user.email,
          "favorites": []
        });

        // Add a new document to the ShoppingList collection with the user's ID
        await db.collection("ShoppingList").doc(user.uid).set({
          // Initialize with any necessary fields
          'Recipe_Items': {},
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegistrationSuccessfulScreenPage(title: 'Smart Grocery'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      print('Error: $e');
      // Show generic error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('An unexpected error occurred. Please try again later.'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Smart Grocery',
          style: TextStyle(
            fontFamily: 'opensans',
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0x00000000),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            // Container(
            //   decoration: const BoxDecoration(
            //     image: DecorationImage(
            //       image: AssetImage("assets/bgimage.jpg"),
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Image.asset('assets/new_logo.png'),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: const Text(
                    "Register:",
                    style: TextStyle(
                      fontFamily: 'opensans',
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 8.0,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: const Color(0xff4417810)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Color(0xff4417810)),
                      ),
                      labelText: 'Enter your Name',
                      labelStyle: const TextStyle(
                        color: Color(0xff4417810),
                        fontFamily: 'opensans',
                      ),
                      hintText: 'Enter your name',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: const Color(0xff4417810)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Color(0xff4417810)),
                      ),
                      labelText: 'Enter your Email ID',
                      labelStyle: const TextStyle(
                        color: Color(0xff4417810),
                        fontFamily: 'opensans',
                      ),
                      hintText: 'Enter valid mail id as abc@uic.edu',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: const Color(0xff4417810)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Color(0xff4417810)),
                      ),
                      labelText: 'Enter your Password',
                      labelStyle: const TextStyle(
                        color: Color(0xff4417810),
                        fontFamily: 'opensans',
                      ),
                      hintText: 'Enter password',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    obscuringCharacter: '*',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: const Color(0xff4417810)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Color(0xff4417810)),
                      ),
                      labelText: 'Re-confirm your Password',
                      labelStyle: const TextStyle(
                        color: Color(0xff4417810),
                        fontFamily: 'opensans',
                      ),
                      hintText: 'Enter password again',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    obscuringCharacter: '*',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 50),
                  width: 300,
                  height: 100,
                  child: FloatingActionButton(
                    onPressed: () async {
                      await registerUsingEmailPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                        context: context,
                      );
                    },
                    backgroundColor: Color(0xff4417810),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontFamily: 'opensans',
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
