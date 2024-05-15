import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Base.dart';
import 'RecipePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class CreatedRecipesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      body: _CreatedRecipesPageContent(),
    );
  }
}

class _CreatedRecipesPageContent extends StatefulWidget {
  @override
  _CreatedRecipesPageContentState createState() => _CreatedRecipesPageContentState();
}

class _CreatedRecipesPageContentState extends State<_CreatedRecipesPageContent> {
  late SharedPreferences prefs;
  String? email;
  String? uid;
  List<Map<String, dynamic>> userRecipes = [];

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
    });
    fetchUserRecipes();
  }

  Future<void> fetchUserRecipes() async {
    try {
      var snapshot = await db.collection('Recipes_test').where('createdBy', isEqualTo: uid).get();
      setState(() {
        userRecipes = snapshot.docs.map((doc) => {
          'data': doc.data(),
          'id': doc.id,
        }).toList();
      });
    } catch (e) {
      print('Failed to fetch user recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Recipes',
          style: TextStyle(
            fontFamily: 'opensans',
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: const Color(0xff4417810),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Builder(builder: (BuildContext context){
        if (userRecipes.isEmpty) {
          return const Text('No Recipes Found', style: TextStyle(
            fontFamily: 'opensans',
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),);
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'These are the recipes created by you:',
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
                  itemCount: userRecipes.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    var recipe = userRecipes[index];
                    Map<String, dynamic> ingredientsMap = recipe['data']['ingredients'];
                    String ingredientsString = ingredientsMap.entries.map((e) => '${e.key[0].toUpperCase() + e.key.substring(1,e.key.length)}: ${e.value}').join(';');
                    List<dynamic> instructionsList = recipe['data']['instructions'];
                    String instructionsString = instructionsList.join(';');
                    bool isApproved = recipe['data']['approved'] ?? false;
                    return ListTile(
                      leading: recipe['data']['image'] != null
                          ? Container(
                        width: 70,
                        height: 70,
                        child: Image.network(
                          recipe['data']['image'],
                          fit: BoxFit.cover,
                        ),
                      )
                          : null,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${recipe['data']['title']}',
                              style: TextStyle(
                                  fontFamily: 'opensans',
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,  // Make the title text thicker
                                  color: isApproved ? const Color(0xff4417810) : Colors.grey)),
                          Text('Status: ${isApproved ? 'Approved' : 'Pending'}',
                              style: TextStyle(
                                  fontFamily: 'opensans',
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal,  // Make the status text thicker
                                  color: isApproved ? Colors.black : Colors.grey)), // Updated this line
                        ],
                      ),
                      trailing: Icon(Icons.person, color: const Color(0xff4417810), size: 20,),
                      onTap: () {
                        _navigateToRecipePage(
                          recipe['data']['title'],
                          ingredientsString,
                          instructionsString,
                          recipe['id'],
                          context,
                        );
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
}