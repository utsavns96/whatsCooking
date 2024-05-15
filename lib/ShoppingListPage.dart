import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgrocery/Base.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'RecipePage.dart';

class ShoppingListPage extends StatefulWidget {
  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  Map<String, List<String>>?
      localRecipeItems; // New variable to store the local state of the recipe items
  Map<String, bool> expansionTileState = {};
  Map<String, bool> isChecked = {};

  void _launchURL() async {
    const url = 'https://www.google.com/maps/search/?api=1&query=grocery+stores+near+me';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> removeFromShoppingList(String recipeName) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    // Check if uid is null
    if (uid == null) {
      return;
    }

    // Remove the recipe from the user's shopping list in Firestore
    await db.collection('ShoppingList').doc(uid).update({
      'Recipe_Items.$recipeName': FieldValue.delete()
    });

    // Remove the recipe from the local state
    localRecipeItems!.remove(recipeName);

    // Show a toast message
    Fluttertoast.showToast(
        msg: "Recipe removed from shopping list successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);

    // Update the state of the widget
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
        body: Scaffold(
          backgroundColor: Colors.white,
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        title: Text(
          'Shopping List',
          style: TextStyle(
            fontFamily: 'opensans',
            fontSize: 25.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xff4417810),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: () async {
          final prefs = await SharedPreferences.getInstance();
          final uid = prefs.getString('uid');
          return db.collection('ShoppingList').doc(uid).get();
        }(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            Map<String, List<String>> recipeItems =
                (data['Recipe_Items'] as Map<String, dynamic> ?? {}).map(
              (key, value) => MapEntry(
                  key, List<String>.from(value.map((item) => item as String))),
            );

            // Set localRecipeItems to recipeItems if localRecipeItems is null
            localRecipeItems ??= recipeItems;

            return Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: ListView(
              children: localRecipeItems!.entries.map((entry) {
                expansionTileState[entry.key] ??= false;
                if (entry.value.isEmpty) {
                  return Container();
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xff4417810),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: expansionTileState[entry.key]!,
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        expansionTileState[entry.key] = expanded;
                      });
                    },
                    trailing: Transform.rotate(
                      angle: expansionTileState[entry.key]! ? 3.14159 : 0,
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: expansionTileState[entry.key]!
                            ? Colors.grey
                            : Color(0xff4417810),
                      ),
                    ),
                    title: Text(
                      entry.key,
                      style: TextStyle(
                        fontFamily: 'opensans',
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xff4417810),
                      ),
                    ),
                    children: entry.value.map((ingredient) {
                      isChecked[ingredient] ??= false;
                      return ListTile(
                        leading: Checkbox(
                          value: isChecked[ingredient],
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked[ingredient] = value!;
                            });
                          },
                          activeColor: Color(0xff4417810),
                        ),
                        title: Text(ingredient, style: TextStyle(
                          fontFamily: 'opensans',
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                          decoration: isChecked[ingredient] ?? false ? TextDecoration.lineThrough : null,
                        )),
                        // trailing: IconButton(
                        //   icon: Icon(Icons.close, color: Colors.red),
                        //   onPressed: () => removeFromShoppingList(entry.key, ingredient),
                        // ),
                      );
                    }).toList()..add(
                      ListTile(
                        title: FutureBuilder<QuerySnapshot>(
                          future: db.collection('Recipes_test').where('title', isEqualTo: entry.key).get(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text("Something went wrong");
                            }

                            if (snapshot.connectionState == ConnectionState.done) {
                              Map<String, dynamic> data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                              String ingredients = (data['ingredients'] as Map<String, dynamic>).entries.map((e) => '${e.key[0].toUpperCase() + e.key.substring(1,e.key.length)}: ${e.value}').join(';');
                              String instructions = (data['instructions'] as List<dynamic>).join(';'); // Updated this line
                              String recipe_id = snapshot.data!.docs.first.id;

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // Navigate to the recipe page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => RecipePage(
                                          recipeName: entry.key,
                                          ingredients: ingredients,
                                          instructions: instructions,
                                          recipe_id: recipe_id,
                                        )),
                                      );
                                    },
                                    child: Text(
                                      'Go to Recipe',
                                      style: TextStyle(
                                        color: Color(0xff4417810),
                                        fontFamily: 'opensans',
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      removeFromShoppingList(entry.key);
                                    },
                                    child: Text(
                                      'Remove Recipe',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: 'opensans',
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Text("Loading");
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ));
          }

          return Text("Loading");
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: _launchURL,
              tooltip: 'Find Grocery Stores',
              backgroundColor: Color(0xff4417810).withOpacity(1), // Set the button color to green
              label: const Text(
              'Find Grocery Stores Nearby',
              style: TextStyle(
                  fontFamily: 'opensans',
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
              ),

            ), icon: const Icon(Icons.store, color: Colors.white, size: 20),

              // child: Container(
              //   width: 150, // Set a specific width for the Container
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min, // Limit the row size to the minimum necessary
              //     children: <Widget>[
              //       Icon(Icons.store, size: 30.0), // The icon
              //       SizedBox(width: 5), // Add some space between the icon and the text
              //       Text(
              //         'Search Stores Near Me', // The text
              //         style: TextStyle(
              //           fontSize: 16.0, // Adjust the font size for readability
              //           fontWeight: FontWeight.bold, // Make the text bold
              //           color: Colors.white, // Set the text color to white for contrast against the green button
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
    );
  }
}