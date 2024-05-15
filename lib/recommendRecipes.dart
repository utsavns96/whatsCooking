import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'RecipePage.dart';
import 'Base.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

void recommendRecipes() => runApp(MaterialApp(
  title: 'smartGrocery',
  home: recRecipes(selectedIngredients: []), // Pass your HashMap here
));

class recRecipes extends StatefulWidget {
  final List<String> selectedIngredients;
  const recRecipes({super.key, required this.selectedIngredients});

  @override
  State<recRecipes> createState() => _recRecipesState();
}

class _recRecipesState extends State<recRecipes> {
  List<DocumentSnapshot> refineRecommendation(List<String> ingredientIds, List<DocumentSnapshot> recipes, bool includeCommonIngredients) {
    List<String> commonIngredientIds = ['da4eT31Ns07V8hN0CuoT',
      'hrPpiB0jx0TxRsdnmtik',
      'ElMRvKMy3eAIrygoHIvt',
      'lFLYglYjMkqDZaWku0jX',
      'zsB0fDqIeEgDOqgMdqVT',
      'jnCajVFmga3xPSjoCuLU',
      'Q7Pr0Ai0aaH3peD6lSYO',
      'iZndMHkI5DUtIUctc9tk',
      '2yGPyjPqs97voVvJoHtL',
      '2UL9k0kNfyhPQKurRAT2',
      'ykcVRi3xlTaW7fqv3DuW'];

    List<DocumentSnapshot> matchingRecipes = [];

    for (var recipe in recipes) {
      var recipeIngredientIds = recipe.get('ingredientIDs');
      bool allIngredientsPresent = true;
      for (var recipeIngredientId in recipeIngredientIds) {
        if (!ingredientIds.contains(recipeIngredientId) && (!includeCommonIngredients || !commonIngredientIds.contains(recipeIngredientId))) {
          allIngredientsPresent = false;
          break;
        }
      }
      if (allIngredientsPresent) {
        matchingRecipes.add(recipe);
      }
    }

    return matchingRecipes;
  }


  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      body: Scaffold(
        //extendBodyBehindAppBar: false,
        appBar: AppBar(
          //automaticallyImplyLeading: false,
          title: const Text(
            'Recommendations',
            style: TextStyle(
              fontFamily: 'opensans',
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xff4417810),
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.white, // Corrected color code
          elevation: 0.0,
        ),
        body: Stack(
            children: <Widget>[
              // Container(
              //   decoration: const BoxDecoration(
              //     image: DecorationImage(
              //       image: AssetImage('assets/bgimage.jpg'),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              FutureBuilder<List<DocumentSnapshot>>(
                future: getRecommendation(widget.selectedIngredients),
                builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<DocumentSnapshot> allRecipes = snapshot.data!;
                    List<DocumentSnapshot> mostRelevantRecipes = refineRecommendation(widget.selectedIngredients, allRecipes, true);
                    //List<DocumentSnapshot> similarRecipes = refineRecommendation(widget.selectedIngredients, allRecipes, false);
                    List<DocumentSnapshot> similarRecipes = allRecipes.where((recipe) => !mostRelevantRecipes.contains(recipe)).toList();
                    return ListView(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(top: 10, left: 15),
                          child: const Text('Most Relevant', style: TextStyle(fontSize: 22, fontFamily: 'opensans', fontWeight: FontWeight.normal, color: Color(0xff4417810))),
                        ),
                        mostRelevantRecipes.isEmpty
                            ? Container(
                            padding: const EdgeInsets.only(top: 10, left: 15),
                            child: const Text('No exact matches found, but you can try one of the below recipes', style: TextStyle(fontSize: 16, fontFamily: 'opensans', fontWeight: FontWeight.normal, color: Colors.black)))
                            : Container(
                            padding: const EdgeInsets.only(top: 10,  left: 15),
                            child: const Text('These recipes use all of the ingredients that you\'ve selected', style: TextStyle(fontSize: 16, fontFamily: 'opensans', fontWeight: FontWeight.normal, color: Colors.black))),
                        ...buildRecipeList(mostRelevantRecipes),
                        Padding(padding: const EdgeInsets.only(top:20, left: 10, right: 10),
                            child: Divider(height: 10, thickness: 1, color: Color(0xff4417810))),
                        Container(
                            padding: const EdgeInsets.only(top: 10, left: 15),
                            child: const Text('Similar Recipes', style: TextStyle(fontSize: 22, fontFamily: 'opensans', fontWeight: FontWeight.normal, color: Color(0xff4417810)))),
                        Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15),
                            child: const Text('These recipes utilize one or more of your available ingredients', style: TextStyle(fontSize: 16, fontFamily: 'opensans', fontWeight: FontWeight.normal, color: Colors.black))),
                        ...buildRecipeList(similarRecipes),
                      ],
                    );
                  }
                },
              )
            ]
        ),
      ),
    );
  }

  Future<String> getRecipeCreator(String createdBy) async {
    String creator;
    var userSnapshot = await db.collection('Users').doc(createdBy).get();
    creator = userSnapshot.data()?['name'] ?? 'Unknown';
    return creator;
  }

  List<Widget> buildRecipeList(List<DocumentSnapshot> recipes) {
    return recipes.map((recipe) {
      return FutureBuilder<String>(
        future: getRecipeCreator(recipe.get('createdBy')),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            String creator = snapshot.data!;
            return ListTile(
              leading: recipe.get('image') != null
                  ? Container(
                width: 70,
                height: 70,
                child: Image.network(
                  recipe.get('image'),
                  fit: BoxFit.cover,
                ),
              )
                  : null,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.get('title'),
                      style: TextStyle(
                          fontFamily: 'opensans',
                          fontSize: 15.0,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xff4417810))),
                  Text('Created by: $creator',
                      style: TextStyle(
                          fontFamily: 'opensans',
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.black)),
                ],
              ),
              trailing: Icon(Icons.person, color: const Color(0xff4417810), size: 20,),
              onTap: () {
                Map<String, dynamic> ingredientsMap = recipe.get('ingredients');
                String ingredientsString = ingredientsMap.entries.map((e) => '${e.key[0].toUpperCase() + e.key.substring(1,e.key.length)}: ${e.value}').join(';');
                List<dynamic> instructionsList = recipe.get('instructions');
                String instructionsString = instructionsList.join(';');

                _navigateToRecipePage(
                    recipe.get('title'),
                    ingredientsString,
                    instructionsString,
                    recipe.id,
                    context
                );
              },
            );
          }
        },
      );
    }).toList();
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


Future<List<DocumentSnapshot>> getRecommendation(List<String> ingredientIds) async {
  print("Getting Recommendations...");
  ingredientIds.forEach((element) {
    print('$element\n');
  });
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final QuerySnapshot querySnapshot = await _firestore
      .collection('Recipes_test')
      .where('ingredientIDs', arrayContainsAny: ingredientIds)
      .get();
  //print('QuerySnapshot: $querySnapshot');
  print('Fetched Recipes:');
  for (var doc in querySnapshot.docs) {
    print('Recipe: ${doc.data()}');
  }
  print('print end');

  return querySnapshot.docs;
}