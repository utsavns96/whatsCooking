import 'package:flutter/material.dart';
import 'package:smartgrocery/login.dart';

void main() {
  runApp(RegistrationSuccessfulPage());
}

class RegistrationSuccessfulPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Cruise',
      home: RegistrationSuccessfulScreen(),
    );
  }
}

class RegistrationSuccessfulScreen extends StatefulWidget {
  const RegistrationSuccessfulScreen({Key? key}) : super(key: key);

  @override
  _RegistrationSuccessfulScreenState createState() =>
      _RegistrationSuccessfulScreenState();
}

class _RegistrationSuccessfulScreenState
    extends State<RegistrationSuccessfulScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const Login(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
      //   title: Text(
      //     'Smart Grocery',
      //     style: TextStyle(
      //       fontFamily: 'opensans',
      //       fontSize: 25.0,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Color(0x00000000),
      //   elevation: 0.0,
      // ),
      // body: Container(
      //   decoration: BoxDecoration(
      //     image: DecorationImage(
      //       image: AssetImage('assets/bgimage.jpg'),
      //       fit: BoxFit.cover,
      //     ),
      //   ),
      // ),
    )
    );
  }
}

class RegistrationSuccessfulScreenPage extends StatefulWidget {
  const RegistrationSuccessfulScreenPage({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  State<RegistrationSuccessfulScreenPage> createState() => _BasicState();
}

class _BasicState extends State<RegistrationSuccessfulScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
        backgroundColor: Color(0x00000000),
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          // Container(
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image: const AssetImage("assets/bgimage.jpg"),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 100.0,
                    color: Colors.green,
                  ),
                ),
                Container(
                  child: const Text(
                    'Registration',
                    style: TextStyle(
                      fontFamily: 'opensans',
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                Container(
                  child: const Text(
                    'Successful',
                    style: TextStyle(
                      fontFamily: 'opensans',
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                Container(
                  child: const Text(
                    'Thank you for registering!',
                    style: TextStyle(
                      fontFamily: 'opensans',
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
