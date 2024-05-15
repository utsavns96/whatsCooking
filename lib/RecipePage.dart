import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RecipePage extends StatefulWidget {
  final String recipeName;
  final String ingredients;
  final String instructions;
  final String recipe_id;

  RecipePage(
      {Key? key,
      required this.recipeName,
      required this.ingredients,
      required this.instructions,
      required this.recipe_id})
      : super(key: key);

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool isFavorite = false;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
    fetchRecipeImage();
  }

  Future<void> fetchRecipeImage() async {
    try {
      var documentSnapshot =
          await db.collection('Recipes_test').doc(widget.recipe_id).get();
      setState(() {
        imageUrl = documentSnapshot.get('image');
      });
    } catch (e) {
      print('Failed to fetch recipe image: $e');
    }
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

  void addToShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    // Check if uid is null
    if (uid == null) {
      return;
    }

    // Splitting ingredients into key-value pairs
    final ingredientMap =
        Map.fromEntries(widget.ingredients.split(';').map((ingredient) {
      final splitIndex = ingredient.indexOf(':');
      final key = ingredient.substring(0, splitIndex).trim();
      return MapEntry(key, '');
    }));

    // List to store the selected ingredients
    final selectedIngredients = <String>[];

    // Show a dialog box
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Ingredients'),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ingredientMap.keys.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ingredient = ingredientMap.keys.elementAt(index);
                    return CheckboxListTile(
                      activeColor: Color(0xff4417810),
                      title: Text(ingredient),
                      value: selectedIngredients.contains(ingredient),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedIngredients.add(ingredient);
                          } else {
                            selectedIngredients.remove(ingredient);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Add to Shopping List', style: TextStyle(color: Color(0xff4417810), fontFamily: 'opensans', fontWeight: FontWeight.w900)),
                  onPressed: () async {
                    // Add the selected ingredients to the user's shopping list in Firestore
                    await db.collection('ShoppingList').doc(uid).set(
                        {
                          'Recipe_Items': {
                            widget.recipeName: selectedIngredients
                          }
                        },
                        SetOptions(
                            merge:
                                true)); // Use SetOptions(merge: true) to merge the new data with the existing data

                    // Show a toast message
                    Fluttertoast.showToast(
                        msg: "Item/items added to shopping list successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void updateRating(double rating) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    // Check if uid is null
    if (uid == null) {
      return;
    }

    // Get the current ratings map
    final doc = await db.collection('Recipes_test').doc(widget.recipe_id).get();
    final ratings = Map<String, double>.from(doc.data()?['rating'] ?? {});

    // Update the user's rating
    ratings[uid] = rating;

    // Update the ratings map in Firestore
    db
        .collection('Recipes_test')
        .doc(widget.recipe_id)
        .update({'rating': ratings});
  }

  double calculateAverageRating(Map<String, double> ratings) {
    if (ratings.isEmpty) {
      return 0.0;
    }
    double sum = 0.0;
    ratings.values.forEach((rating) => sum += rating);
    return sum / ratings.length;
  }

  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    // Splitting ingredients into key-value pairs
    final ingredientMap =
        Map.fromEntries(widget.ingredients.split(';').map((ingredient) {
      final splitIndex = ingredient.indexOf(':');
      final key = ingredient.substring(0, splitIndex).trim();
      final value = ingredient.substring(splitIndex + 1).trim();
      return MapEntry(key, value);
    }));

    return Scaffold(
        appBar: AppBar(
          // title: const Text(
          //   'Recipe Details',
          //   style: TextStyle(
          //     fontFamily: 'Raleway',
          //     fontSize: 25.0,
          //     fontWeight: FontWeight.bold,
          //     color: Color(0xff4417810), // Change the text color to green
          //   ),
          // ),
          centerTitle: false,
          backgroundColor: Colors.white, // Change the background color to white
          elevation: 0.0,
          iconTheme: IconThemeData(
              color:
                  Color(0xff4417810)), // Change the back button color to green
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                children:[
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.green),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final uid = prefs.getString('uid');
                      if (isFavorite) {
                        db.collection('Users').doc(uid).update({
                          "favorites": FieldValue.arrayRemove([widget.recipe_id])
                        });
                        Fluttertoast.showToast(
                          msg: '${widget.recipeName} removed from favorites!',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                      } else {
                        db.collection('Users').doc(uid).update({
                          "favorites": FieldValue.arrayUnion([widget.recipe_id])
                        });
                        Fluttertoast.showToast(
                          msg: '${widget.recipeName} added to favorites!',
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
                    style: TextStyle(color: Colors.green, fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 15.0),
                  ),
                ],
              ),
            ),
          ],
        ),

        body: Stack(
          children: <Widget>[
            ListView(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: db.collection('Recipes_test').doc(widget.recipe_id).get(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text("Something went wrong");
                        }

                        if (snapshot.hasData && !snapshot.data!.exists) {
                          return Text("Document does not exist");
                        }

                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                          Map<String, double> ratings = Map<String, double>.from(data['rating'] ?? {});
                          double averageRating = calculateAverageRating(ratings);
                          List<String> tags = List<String>.from(data['tags'] ?? []);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.recipeName,
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Rating: ${averageRating.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(width: 10.0), // Add some space between the two Text widgets
                                  Text(
                                    '(${ratings.length})',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 8.0, // gap between adjacent chips
                                runSpacing: 4.0, // gap between lines
                                children: tags.map((tag) => Chip(
                                  label: Text(tag[0].toUpperCase() + tag.substring(1, tag.length)),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Color(0xff4417810), width: 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                )).toList(),
                              ),
                            ],
                          );
                        }

                        return Text("Loading");
                      },
                    ),

                    const Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5)
                    ),
                    if (imageUrl != null)
                      Container(
                        width: double.infinity, // 100% width
                        height: MediaQuery.of(context).size.height * 0.3, // fixed height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover, // ensure the image covers the entire container
                          ),
                        ),
                      ), // Display the recipe image
                    const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Divider(
                            height: 20,
                            thickness: 2,
                            color: Color(0xff4417810))),
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff4417810)),
                    ),
                    const SizedBox(height: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ingredientMap.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                // child: Text(
                                //   '${entry.key}: ${entry.value}',
                                //   softWrap: true, // This will make the text wrap around
                                // ),
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '${entry.key}: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: entry.value,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed:
                            addToShoppingList, // Call the new function when the button is clicked
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xff4417810), // background color
                        ),
                        child: Text('Add to Shopping List',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff4417810),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: widget.instructions
                    //       .split(';')
                    //       .map((step) => Text('• $step'))
                    //       .toList(),
                    // ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.instructions
                          .split(';')
                          .asMap()
                          .entries
                          .map((entry) {
                        int stepNumber = entry.key + 1;
                        String step = entry.value;
                        // return Text('Step $stepNumber: \n$step\n',);
                        return RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Step $stepNumber:\n',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '$step\n',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                          .toList(),
                    ),

                    const SizedBox(height: 24.0),
                    const Text(
                      'Rate this Recipe:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4417810),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                          updateRating(
                              rating); // Update the rating in Firestore
                        },
                      ),
                    ),
                    // const SizedBox(height: 24.0),
                    // Center(
                    //   child: ElevatedButton(
                    //     onPressed: () async {
                    //       final prefs = await SharedPreferences.getInstance();
                    //       final uid = prefs.getString('uid');
                    //       if (isFavorite) {
                    //         db.collection('Users').doc(uid).update({
                    //           "favorites":
                    //               FieldValue.arrayRemove([widget.recipe_id])
                    //         });
                    //         Fluttertoast.showToast(
                    //           msg:
                    //               '${widget.recipeName} removed from favorites!',
                    //           toastLength: Toast.LENGTH_SHORT,
                    //           gravity: ToastGravity.BOTTOM,
                    //           backgroundColor: Colors.red,
                    //           textColor: Colors.white,
                    //         );
                    //       } else {
                    //         db.collection('Users').doc(uid).update({
                    //           "favorites":
                    //               FieldValue.arrayUnion([widget.recipe_id])
                    //         });
                    //         Fluttertoast.showToast(
                    //           msg: '${widget.recipeName} added to favorites!',
                    //           toastLength: Toast.LENGTH_SHORT,
                    //           gravity: ToastGravity.BOTTOM,
                    //           backgroundColor: Colors.red,
                    //           textColor: Colors.white,
                    //         );
                    //       }
                    //       setState(() {
                    //         isFavorite = !isFavorite;
                    //       });
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor:
                    //           const Color(0xff4417810), // background color
                    //     ),
                    //     child: Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Icon(Icons.favorite,
                    //             color: isFavorite ? Colors.red : Colors.white),
                    //         SizedBox(width: 8.0),
                    //         Text('Favorite',
                    //             style: TextStyle(color: Colors.white)),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ]),
          ],
        ));
  }
}
