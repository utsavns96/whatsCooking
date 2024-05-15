import 'dart:async';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgrocery/firebase_options.dart';
import 'Base.dart';
import 'RecipePage.dart';
import 'ingredientsSelectionSearch.dart';
import 'profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(
      title: 'smartGrocery',
      home: home(title: 'smartGrocery',)
  ));
}

class home extends StatefulWidget {
  const home({super.key, required String title});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  late SharedPreferences prefs;
  String? email;
  String? uid;
  String? userName;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchTextNotifier = ValueNotifier<String>('');
  final StreamController<String> _searchTextStreamController = StreamController<String>();
  List<String> categories = ['vegetarian', 'gluten-free', 'breakfast', 'dessert', 'non-vegetarian', 'vegan', 'low sodium'];
  List<String> selectedCategories = [];
  List<String> previousSelectedCategories = [];
  List<Map<String, dynamic>> randomRecipes = [];
  final ValueNotifier<bool> _resetController = ValueNotifier<bool>(false);
  late Future<List<Map<String, dynamic>>> recipesFuture;

  Future<List<Map<String, dynamic>>> getRecipes() async {
    print("Called getRecipes()");
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Recipes_test').where('approved', isEqualTo: true).get();
    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<String> getUserName(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    return userData['name'] ?? 'User';
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchTextNotifier.value = _searchController.text;
    });
    SharedPreferences.getInstance().then((prefs) {
      if (prefs != null) {
        setState(() {
          this.prefs = prefs;
          email = prefs.getString('email');
          uid = prefs.getString('uid');
          if (uid != null) {
            getUserName(uid!).then((name) {
              setState(() {
                userName = name;
              });
            });
          }
        });
      }
    });
    recipesFuture = getRecipes();
    print("Calling getRecipes() from initState()");
    recipesFuture.then((recipes) {
      var rng = new Random();
      for (var i = 0; i < 5; i++) {
        randomRecipes.add(recipes[rng.nextInt(recipes.length)]);
      }
      setState(() {});
    });
    initUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTextNotifier.dispose();
    super.dispose();
  }

  void initUser() async {
    prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    uid = prefs.getString('uid');
    String name = await getUserName(uid!);
    setState(() {
      prefs.setString('name', name);
    });
  }

  ValueNotifier<int> _current = ValueNotifier<int>(0);
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {

    return BaseWidget(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child:
                CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      expandedHeight: MediaQuery.of(context).size.height * 0.43,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: <Widget>[
                            // Title
                            Padding(
                              padding: const EdgeInsets.only(top:2, left: 15, right: 10, bottom: 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: 'Hello, ', style: TextStyle(fontSize: 28, fontFamily: 'opensans', color: Colors.black)),
                                      TextSpan(text: '${userName ?? 'User'}!', style: const TextStyle(color: Color(0xff4417810), fontSize: 28, fontFamily: 'opensans')),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Search bar
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: FutureBuilder<List<Map<String, dynamic>>>(
                                future: getRecipes(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                                  if (snapshot.hasData) {
                                    return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15, top: 5, bottom: 5),
                                        child: Autocomplete<String>(
                                          optionsBuilder: (TextEditingValue textEditingValue) {
                                            if (textEditingValue.text == '') {
                                              return const Iterable<String>.empty();
                                            }
                                            var matchingOptions = snapshot.data!
                                                .map<String>((item) => item['title'] ?? '')
                                                .where((String option) {
                                              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                            }).toList();
                                            if (matchingOptions.isEmpty) {
                                              return ['No match found for \"${textEditingValue.text}\"'];
                                            }
                                            return matchingOptions;
                                          },
                                          onSelected: (String selection) {
                                            var recipe = (snapshot.data!.where((element) => element['title'] == selection).toList())[0];
                                            _navigateToRecipePage(
                                              selection,
                                              recipe['ingredients'].entries
                                                  .map((e) => '${e.key[0].toUpperCase() + e.key.substring(1,e.key.length)}: ${e.value}')
                                                  .join(';'),
                                              recipe['instructions'].join(';'),
                                              recipe['id'],
                                              context,
                                            );
                                          },
                                          fieldViewBuilder: (BuildContext context,
                                              TextEditingController
                                              fieldTextEditingController,
                                              FocusNode fieldFocusNode,
                                              VoidCallback onFieldSubmitted) {
                                            if (_resetController.value) {
                                              WidgetsBinding.instance!
                                                  .addPostFrameCallback((_) {
                                                _resetController.value = false;
                                                fieldTextEditingController.clear();
                                              });
                                            }
                                            return Padding(
                                                padding: EdgeInsets.only(bottom: 10),
                                                child: TextField(
                                                  controller: fieldTextEditingController,
                                                  focusNode: fieldFocusNode,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: BorderSide(
                                                          color: const Color(0xff4417810)),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey), // Set the border color to blue when tapped
                                                    ),
                                                    hintText:
                                                    'Start typing for suggestions...',
                                                    hintStyle: TextStyle(
                                                        fontSize: 15.0,
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight.normal,
                                                        fontFamily: 'opensans'),
                                                    suffixIcon: ValueListenableBuilder<
                                                        TextEditingValue>(
                                                      valueListenable:
                                                      fieldTextEditingController,
                                                      builder: (BuildContext context,
                                                          TextEditingValue value,
                                                          Widget? child) {
                                                        return IconButton(
                                                          icon: Icon(
                                                              value.text.isEmpty
                                                                  ? Icons.search
                                                                  : Icons.close,
                                                              color: Colors.grey),
                                                          onPressed: value.text.isEmpty
                                                              ? null
                                                              : () =>
                                                              fieldTextEditingController
                                                                  .clear(),
                                                        );
                                                      },
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors
                                                        .white, // Set the background color to green
                                                    focusColor: Colors.green,
                                                  ),
                                                ));
                                          },
                                          optionsViewBuilder: (BuildContext context,
                                              AutocompleteOnSelected<String> onSelected,
                                              Iterable<String> options) {
                                            double screenWidth =
                                                MediaQuery.of(context).size.width;
                                            return Align(
                                              alignment: Alignment.topLeft,
                                              child: Material(
                                                elevation: 10.0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8)), // Rounded corners
                                                child: SizedBox(
                                                  width: screenWidth -
                                                      30, // Subtract the desired padding from the screen width
                                                  child: Container(
                                                    color: Colors.white60, // Change color
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0, right: 5), // Add horizontal padding
                                                      child: ListView.builder(
                                                        itemCount: options.length,
                                                        itemBuilder: (BuildContext context,
                                                            int index) {
                                                          final String option =
                                                          options.elementAt(index);
                                                          return GestureDetector(
                                                            onTap: () {
                                                              onSelected(option);
                                                            },
                                                            child: ListTile(
                                                              contentPadding:EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                                              visualDensity: VisualDensity(vertical: -4),
                                                              title: Text(option),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ));
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              ),
                            ),
                            // New Recipes Heading
                            Padding(
                              padding: EdgeInsets.only(bottom: 4.0, left: 15),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  'New Recipes',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'opensans',
                                  ),
                                ),
                              ),
                            ),
                            //Carousel
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Column(
                                children: [
                                  CarouselSlider(
                                    carouselController: buttonCarouselController,
                                    options: CarouselOptions(
                                        height: MediaQuery.of(context).size.height * 0.2,
                                        onPageChanged: (index, reason) {
                                          _current.value = index;
                                        }
                                    ),
                                    items: randomRecipes.map((recipe) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Map<String, dynamic> ingredientsMap = recipe['ingredients'];
                                                String ingredientsString = ingredientsMap.entries.map((e) => '${e.key[0].toUpperCase() + e.key.substring(1,e.key.length)}: ${e.value}').join(';');
                                                List<dynamic> instructionsList = recipe['instructions'];
                                                String instructionsString = instructionsList.join(';');

                                                _navigateToRecipePage(
                                                  recipe['title'],
                                                  ingredientsString,
                                                  instructionsString,
                                                  recipe['id'],
                                                  context,
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(15.0),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      width: MediaQuery.of(context).size.width,
                                                      decoration: BoxDecoration(
                                                        color: Colors.amber,
                                                        image: DecorationImage(
                                                          image: NetworkImage(recipe['image']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 0,
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        color: Colors.black.withOpacity(0.5),
                                                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                        child: Text(
                                                          recipe['title'],
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20,
                                                            fontFamily: 'opensans',
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  ValueListenableBuilder<int>(
                                    valueListenable: _current,
                                    builder: (context, value, child) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: randomRecipes.map((recipe) {
                                          int index = randomRecipes.indexOf(recipe);
                                          return Container(
                                            width: 8.0,
                                            height: 8.0,
                                            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _current.value == index
                                                  ? Color.fromRGBO(0, 0, 0, 0.9)
                                                  : Color.fromRGBO(0, 0, 0, 0.4),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        minHeight: 60.0,
                        maxHeight: 60.0,
                        child: Container(
                          color: Colors.white,
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15.0),
                                    child: const Text(
                                      'Browse Recipes',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontFamily: 'opensans',
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    child: Stack(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.filter_list, color: Color(0xff4417810)), // This is the filter icon
                                            SizedBox(width: 5), // This adds some spacing between the icon and the text
                                            Text('FILTER', style: TextStyle(color: Color(0xff4417810), fontFamily: 'opensans')), // This is the text
                                          ],
                                        ),
                                      ],
                                    ),
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return MultiSelectDialog(
                                            items: categories.map((category) => MultiSelectItem(category, toBeginningOfSentenceCase(category) ?? '')).toList(),
                                            initialValue: selectedCategories,
                                            onConfirm: (values) {
                                              List<String> newSelectedCategories = values.map((filter) => filter.toLowerCase()).toList();
                                              if (!listEquals(newSelectedCategories, previousSelectedCategories)) {
                                                selectedCategories = newSelectedCategories;
                                                previousSelectedCategories = List.from(newSelectedCategories);
                                                setState(() {});
                                              }
                                            },
                                            selectedColor: const Color(0xff4417810),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Positioned(
                                top: MediaQuery.of(context).size.width*0.1,  // Adjust this to position the indicator
                                left: MediaQuery.of(context).size.width*0.45,  // Adjust this to position the indicator
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  // decoration: BoxDecoration(
                                  //   color: Colors.red,  // Change this to your desired color
                                  //   borderRadius: BorderRadius.circular(20),  // This makes the pill shape
                                  // ),
                                  child:Container(
                                    height: 4.0, // Adjust this to change the thickness of the line
                                    width: 30.0, // Adjust this to change the length of the line
                                    color: Colors.grey, // Change this to your desired color
                                  )/*Text(
                                    'Pull up',  // Change this to your desired text
                                    style: TextStyle(color: Colors.white),  // Change this to your desired text style
                                  ),*/
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: RecipeList(selectedCategories: selectedCategories),
                    ),
                  ],
                ),
            ),
          ),
        ),
    );
  }


  void _navigateToRecipePage(String recipeName, String recipeIngredients,
      String recipeInstructions, String recipeId, BuildContext context) {
    setState(() {
      _resetController.value = true;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePage(
            recipeName: recipeName,
            ingredients: recipeIngredients,
            instructions: recipeInstructions,
            recipe_id: recipeId
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class RecipeList extends StatefulWidget {
  final List<String> selectedCategories;

  RecipeList({required this.selectedCategories});

  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  late Future<List<Map<String, dynamic>>> recipesFuture;
  Future<List<Map<String, dynamic>>> getRecipes() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Recipes_test').where('approved', isEqualTo: true).get();
    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    recipesFuture = getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: recipesFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          print("Called getRecipes() from RecipeList");
          List<Map<String, dynamic>> recipes = snapshot.data!;
          List<Map<String, dynamic>> filteredRecipesData;
          if (widget.selectedCategories.isEmpty) {
            filteredRecipesData = recipes;
          } else {
            filteredRecipesData = recipes.where((recipe) {
              List<String> recipeTags = List<String>.from(recipe['tags']);
              return recipeTags.any((tag) => widget.selectedCategories.contains(tag));
            }).toList();
          }

          List<Widget> filteredRecipes = filteredRecipesData.map((recipe) {
            Map<String, dynamic> ingredientsMap = recipe['ingredients'];
            String ingredientsString = ingredientsMap.entries.map((e) => '${e.key[0].toUpperCase() + e.key.substring(1,e.key.length)}: ${e.value}').join(';');
            List<dynamic> instructionsList = recipe['instructions'];
            String instructionsString = instructionsList.join(';');
            List<String> tags = recipe['tags'] != null ? List<String>.from(recipe['tags']) : [];
            return ListTile(
              leading: recipe['image'] != null
                  ? Container(
                width: 55,
                height: 55,
                child: Image.network(
                  recipe['image'],
                  fit: BoxFit.cover,
                ),
              )
                  : null,
              title: Text('${recipe['title']}',
                  style: TextStyle(
                      fontFamily: 'opensans',
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xff4417810))),
              trailing: Icon(Icons.person, color: const Color(0xff4417810), size: 20,),
              onTap: () {
                _navigateToRecipePage(
                  recipe['title'],
                  ingredientsString,
                  instructionsString,
                  recipe['id'],
                  context,
                );
              },
            );
          }).toList();

          return Column(children: filteredRecipes);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _navigateToRecipePage(String recipeName, String recipeIngredients,
      String recipeInstructions, String recipeId, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePage(
            recipeName: recipeName,
            ingredients: recipeIngredients,
            instructions: recipeInstructions,
            recipe_id: recipeId
        ),
      ),
    );
  }
}