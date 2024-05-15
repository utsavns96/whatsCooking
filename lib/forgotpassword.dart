import 'package:flutter/material.dart';

void forgotpasswordpage() => runApp(const MaterialApp(
  title: 'Campus Cruise',
  home: forgotpasswordscreen(),
));

class forgotpasswordscreen extends StatefulWidget {
  const forgotpasswordscreen({super.key});

  @override
  State<forgotpasswordscreen> createState() => _forgotpasswordscreenState();
}

class _forgotpasswordscreenState extends State<forgotpasswordscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Smart Grocery',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0x00000000),
        elevation: 0.0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bgimage.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreenPage extends StatefulWidget {
  const ForgotPasswordScreenPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ForgotPasswordScreenPage> createState() => _basicState();
}

class _basicState extends State<ForgotPasswordScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: const Text(
            'Forgot Password',
            style: TextStyle(
              fontFamily: 'opensans',
              //fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Color(0xff4417810),
            ),
          ),
          centerTitle: false,
          backgroundColor: const Color(0x00000000),
          elevation: 0.0,
          iconTheme: const IconThemeData(
            color: Color(0xff4417810),
          )
        ),
        body: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage("assets/bgimage.png"),
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 100),
                  child: Image.asset('assets/new_logo.png')),
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 50),
                  child: const Text(
                    "Enter your email:",
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0), // Set the border radius
                        borderSide: BorderSide(color: Color(0xff4417810)), // Set the border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0), // Set the border radius when focused
                        borderSide: BorderSide(color: Color(0xff4417810), width: 2), // Set the border color when focused
                      ),
                      labelText: 'Enter your Email ID',
                      labelStyle: TextStyle(
                        color: Color(0xff4417810),
                        fontFamily: 'opensans',
                      ),
                      hintText: 'Enter valid mail id as abc@gmail.com',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.only(top: 50),
                    width: 300,
                    height: 100,
                    child: FloatingActionButton(
                      onPressed: (){
                        },
                      backgroundColor: Color(0xff4417810),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: const Text('Get reset link',
                          style: TextStyle(
                            fontFamily: 'opensans',
                            fontSize: 20.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                      ),
                    ),
                ),
              ],
            ),
          ],
        )
    );
  }
}
