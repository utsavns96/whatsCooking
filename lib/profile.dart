import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Base.dart';
import 'CreatedRecipesPage.dart';
import 'FavoritesPage.dart';
import 'ShoppingListPage.dart';  // Import ShoppingListPage

final FirebaseFirestore db = FirebaseFirestore.instance;

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      body: _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatefulWidget {

  @override
  _ProfilePageContentState createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<_ProfilePageContent> {
  late SharedPreferences prefs;
  String? email;
  String? uid;
  String? name;
  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      uid = prefs.getString('uid');
      name = prefs.getString('name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,  // Add this line
        title: Container(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'opensans',
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: const Color(0xff4417810),
            ),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40), // Adjust the height as needed
                Row(
                  children: [
                    SizedBox(width: 20),  // Add some left padding to the Row
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.account_circle,
                        size: 100,
                        color: const Color(0xff4417810),
                      ),
                    ),
                    SizedBox(width: 20),  // Add some spacing between the icon and the text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Text(
                          name!,
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'opensans'),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          email!,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, fontFamily: 'opensans'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                    )
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FavoritesPage()),
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Favorite',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16.0),  // Add this line
                          ],
                        ),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(Colors.grey[150]),
                        foregroundColor: MaterialStateProperty.all(const Color(0xff4417810)),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreatedRecipesPage()),
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Recipes',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16.0),  // Add this line
                          ],
                        ),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(Colors.grey[150]),
                        foregroundColor: MaterialStateProperty.all(const Color(0xff4417810) ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ShoppingListPage()),
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'View Shopping List',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16.0),  // Add this line
                          ],
                        ),
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(Colors.grey[150]),
                        foregroundColor: MaterialStateProperty.all(const Color(0xff4417810)),
                      ),
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