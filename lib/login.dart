import 'package:smartgrocery/main.dart';
import 'package:smartgrocery/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartgrocery/firebase_options.dart';
import 'forgotpassword.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  // FirebaseAuth.instance.useAppLanguage();
  // await Firebase.initializeApp();
  runApp(const MaterialApp(
    title: 'smartGrocery',
    home: Login(),
  ));
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<FirebaseApp> _initalizeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  static Future<User?> loginUsingEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user=not-found") {
        print("No user found for that email");
      }
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: false,
          resizeToAvoidBottomInset: false,
          // appBar: AppBar(
          //   title: const Text(
          //     'Campus Cruise',
          //     style: TextStyle(
          //       fontFamily: 'Raleway',
          //       fontSize: 25.0,
          //       fontWeight: FontWeight.bold,
          //       color: Colors.white,
          //     ),
          //   ),
          //   centerTitle: true,
          //   backgroundColor: const Color(0x00000000),
          //   elevation: 0.0,
          // ),
          body: Stack(
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
                      padding: const EdgeInsets.only(top: 50),
                      child: Image.asset('assets/new_logo.png')),
                  Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontFamily: 'opensans',
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 8.0,
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
                        labelText: 'Email',
                        labelStyle: const TextStyle(
                          color: Color(0xff4417810),
                          fontFamily: 'opensans',
                        ),
                        hintText: 'Enter valid Email ID as abc@uic.edu',
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
                        labelText: 'Password',
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
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreenPage(
                                      title: 'Smart Grocery')));
                        },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                        color: Colors.black,
                        )
                      )
                    )
                  ),
                  Container(
                      padding: const EdgeInsets.only(top: 10),
                      width: 250,
                      height: 70,
                      child: FloatingActionButton(
                        onPressed: () async {
                          User? user = await loginUsingEmailPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                              context: context);
                          print(user);
                          if (user != null) {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();

                            prefs.setString('email', _emailController.text);
                            prefs.setString('uid', user.uid);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const home(
                                        title: 'smartGrocery')));
                          }
                          //TO DO: Add login functionality
                        },
                        backgroundColor: Color(0xff4417810),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: const Text('Login',
                            style: TextStyle(
                              fontFamily: 'opensans',
                              fontSize: 25.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            )),
                      )),
                  Container(
                    padding: const EdgeInsets.only(top: 40),
                    child: const Text(
                      "New user? Click on the button below to register",
                      style: TextStyle(
                        fontFamily: 'opensans',
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.only(top: 50),
                      width: 150,
                      height: 100,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(
                                      title: 'Smart Grocery')));
                        },
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: const Text('Register',
                            style: TextStyle(
                              fontFamily: 'opensans',
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal,
                              color: Color(0xff4417810),
                            )),
                      )),
                ],
              ),
            ],
          ),
        ));
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure you want to exit?',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
            content: const Text('Click Yes to exit, No continue',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
            actions: <Widget>[
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: const Text("NO",
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    )),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(true),
                child: const Text("YES",
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue,
                    )),
              ),
            ],
          ),
        ) ??
        false;
  }

}
