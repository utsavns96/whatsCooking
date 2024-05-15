import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RecipePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'RecipeWebViewPage.dart';


final FirebaseFirestore db = FirebaseFirestore.instance;

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      body: _FavoritesPageContent(),
    );
  }
}

class _FavoritesPageContent extends StatefulWidget {
  @override
  _FavoritesPageContentState createState() => _FavoritesPageContentState();
}

class _FavoritesPageContentState extends State<_FavoritesPageContent> {
  late SharedPreferences prefs;
  String? email;
  String? uid;
  String? name;

  List<String> favoriteRecipeids = [];

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
    fetchFavorites();
  }


  Future<void> fetchFavorites() async {
    print(uid);
    try {
      var Snapshot = await db.collection('Users').doc(uid).get();
      if (Snapshot.exists) {
        Map<String, dynamic>? data = Snapshot.data();
        setState(() {
          favoriteRecipeids = List<String>.from(data?['favorites'] ?? []);
        });
      }
    } catch (e) {
      print('Failed to fetch favorites: $e');
    }
  }

  Future<Map<String, dynamic>> fetchRecipe(String recipeId) async {
    if (Uri.tryParse(recipeId)?.hasScheme == true) {
      // If recipeId is a URL, fetch the JSON from the API
      var response = await http.get(Uri.parse(recipeId));
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        // Extract the necessary information from the JSON response
        print(jsonResponse.toString());
        String recipeUrl = jsonResponse['recipe']['url'];
        String recipeName = jsonResponse['recipe']['label'];
        String recipeImage = jsonResponse['recipe']['images']['REGULAR']['url'];
        String creator = jsonResponse['recipe']['source'];
        return {
          'data': {
            'url': recipeUrl,
            'image': recipeImage,
            'createdBy': creator
          },
          'id': recipeId,
          'name': recipeName,

          // Add the recipe name to the returned map
        };
      } else {
        print('Failed to load recipe from API');
        return {};
      }
    } else {
      // If recipeId is not a URL, fetch the recipe from Firestore
      try {
        var snapshot = await db.collection('Recipes_test').doc(recipeId).get();
        if (snapshot.exists) {
          var createdBy = snapshot.data()!['createdBy'];
          var userSnapshot = await db.collection('Users').doc(createdBy).get();
          var creator = userSnapshot.data()?['name'] ?? 'Unknown';
          return {
            'data': {
              ...snapshot.data()!,
              'createdBy': creator,
            },
            'id': snapshot.id,
            'name': snapshot.data()!['title'], // Add the recipe name to the returned map
          };
        }
      } catch (e) {
        print('Failed to fetch recipe: $e');
      }
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(
            fontFamily: 'opensans',
            fontSize: 25.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xff4417810),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Builder(builder: (BuildContext context){
        if (favoriteRecipeids.isEmpty) {
          return const Text('No Recipes Found', style: TextStyle(
            fontFamily: 'opensans',
            fontSize: 25.0,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),);
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'These are your favorite recipes:',
                  style: TextStyle(
                    fontFamily: 'opensans',
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: favoriteRecipeids.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    return FutureBuilder<Map<String, dynamic>>(
                      future: fetchRecipe(favoriteRecipeids[index]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          var recipe = snapshot.data!;
                          return ListTile(
                            leading: recipe['data']['image'] != null
                                ? Container(
                              width: 50.0, // specify the width of the image
                              height: 50.0, // specify the height of the image
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(recipe['data']['image']),
                                  fit: BoxFit.cover, // ensure the image covers the entire container
                                ),
                              ),
                            )
                                : null,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${recipe['name']}',
                                  style: TextStyle(
                                    fontFamily: 'opensans',
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff4417810),
                                  ),
                                ),
                                Text('Created by: ${recipe['data']['createdBy']}',
                                  style: TextStyle(
                                    fontFamily: 'opensans',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            trailing: recipe['data']['url'] == null
                                ? Icon(Icons.person, color: const Color(0xff4417810), size: 20)
                                : null,
                            onTap: () {
                              if (recipe['data']['url'] != null) {
                                _navigateToRecipeWebViewPage(recipe['data']['url'], recipe['id'], context);
                                return;
                              } else {
                                Map<String, dynamic> ingredientsMap = recipe['data']['ingredients'];
                                String ingredientsString = ingredientsMap.entries.map((e) => '${e.key[0].toUpperCase() + e.key.substring(1,e.key.length)}: ${e.value}').join(';');
                                List<dynamic> instructionsList = recipe['data']['instructions'];
                                String instructionsString = instructionsList.join(';');
                                _navigateToRecipePage(
                                    recipe['data']['title'],
                                    ingredientsString,
                                    instructionsString,
                                    recipe['id'],
                                    context
                                );
                              }
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
      }),
      backgroundColor: Colors.white,
    );
  }

  void _navigateToRecipePage(String recipeName, String recipeIngredients,
      String recipeInstructions, String recipe_id, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePage(
            recipeName: recipeName,
            ingredients: recipeIngredients,
            instructions: recipeInstructions,
            recipe_id: recipe_id
        ),
      ),
    );
  }

  void _navigateToRecipeWebViewPage(String recipeUrl, String recipe_id , BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeWebViewPage(
            recipeUrl: recipeUrl,
            recipe_id: recipe_id // Get the recipe ID from the URL,
        ),
      ),
    );
  }

}
