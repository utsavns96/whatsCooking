import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*
================================================================================
Draws the webview for the recipe
================================================================================
 */
class RecipeWebViewPage extends StatefulWidget {
  final String recipeUrl;
  final String recipe_id;

  RecipeWebViewPage({required this.recipeUrl, required this.recipe_id});

  @override
  _RecipeWebViewPageState createState() => _RecipeWebViewPageState();
}

class _RecipeWebViewPageState extends State<RecipeWebViewPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  Future<void> checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    final doc = await db.collection('Users').doc(uid).get();
    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
    setState(() {
      isFavorite = favorites.contains(widget.recipe_id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // You can do additional things here if needed
        return true; // return true if the route should be popped
      },
      child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Color(0xff4417810)),
  //title: Text('Recipe'),
  actions: [
    Row(
      children: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.green),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final uid = prefs.getString('uid');
            if (isFavorite) {
              db.collection('Users').doc(uid).update({"favorites": FieldValue.arrayRemove([widget.recipe_id])});
              Fluttertoast.showToast(
                msg: 'Recipe removed from favorites!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            } else {
              db.collection('Users').doc(uid).update({"favorites": FieldValue.arrayUnion([widget.recipe_id])});
              Fluttertoast.showToast(
                msg: 'Recipe added to favorites!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            }
            setState(() {
              isFavorite = !isFavorite;
            });
          },
        ),
          Text(
          //isFavorite ? 'Favorited' : 'Not Favorited',
          'Favorite',
          style: TextStyle(color: Colors.green, fontFamily: 'opensans', fontWeight: FontWeight.bold, fontSize: 15.0),
        ),

      ],
    ),
  ],
),
          body: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.recipeUrl),
            ),
          )
      ),
    );
  }
}
