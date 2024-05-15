import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartgrocery/recommendRecipes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Base.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

void ingredientsSelectionSearch() => runApp(MaterialApp(
      title: 'smartGrocery',
      home: IngredientsSelection(),
    ));

class IngredientsSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      body: _IngredientsSelectionContent(),
    );
  }
}

class _IngredientsSelectionContent extends StatefulWidget {
  static final ValueNotifier<bool> resetNotifier =
      ValueNotifier<bool>(false); // Moved resetNotifier here

  @override
  _IngredientsSelectionContentState createState() =>
      _IngredientsSelectionContentState();
}

class _IngredientsSelectionContentState
    extends State<_IngredientsSelectionContent> {
  List<String> _selectedIngredientIds = [];

  late Future<List<Map<String, dynamic>>> _ingredientsFuture;
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _resetController = ValueNotifier<bool>(false);
  Map<String, String> _ingredientNameToId = {};

  Future<List<Map<String, dynamic>>> getIngredients() async {
    final QuerySnapshot result = await db.collection('Ingredients').get();
    final List<DocumentSnapshot> documents = result.docs;
    List<Map<String, dynamic>> ingredients = [];
    for (var document in documents) {
      var ingredient = {
        'name': document.get('name'),
        'id': document.id,
      };
      ingredients.add(ingredient);
      _ingredientNameToId[ingredient['name']] = ingredient['id'];
    }
    ingredients.sort((a, b) {
      var aName = a['name'] ?? '';
      var bName = b['name'] ?? '';
      return aName.compareTo(bName);
    });
    //print('Ingredients: $ingredients');
    return ingredients;
  }

  @override
  void initState() {
    super.initState();
    _selectedIngredientIds = [];
    _IngredientsSelectionContent.resetNotifier
        .addListener(_resetState); // Updated this line
    _ingredientsFuture = getIngredients();
  }

  @override
  void dispose() {
    _IngredientsSelectionContent.resetNotifier
        .removeListener(_resetState); // Updated this line
    super.dispose();
  }

  void _resetState() {
    if (_IngredientsSelectionContent.resetNotifier.value) {
      // Updated this line
      setState(() {
        _selectedIngredientIds = [];
      });
      _IngredientsSelectionContent.resetNotifier.value =
          false; // Updated this line
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      /*appBar: AppBar(
        title: const Text(
          'Select Ingredients',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff4417810),
        elevation: 0.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Select Ingredients'),
                      content: const Text("Please select the ingredients you have. Each ingredient can be added once and will be shown below the search bar. Some common ingredients like salt and oil are added automatically for you."
                          "\n\nWhen you tap on \'Recommend\', the app will show two sets of recipes:"
                          "\n\'Most Relevant\' Recipes that contain all the ingredients you have selected and\n"
                          "\'Similar Recipes\' that contain some of the ingredients you have selected.\n\nYou can tap on the recipe to view the details."),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Close', style: TextStyle(
                              fontSize: 18.0,
                              //fontWeight: FontWeight.bold,
                              color: Colors.grey
                          )),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(
                Icons.question_mark,
                size: 26.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),*/
        floatingActionButton: FloatingActionButton.extended(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xff4417810),
            onPressed: () {
              if (_selectedIngredientIds.isEmpty) {
                Fluttertoast.showToast(
                  msg: 'Please select ingredients first',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => recRecipes(
                            selectedIngredients: _selectedIngredientIds
                        )
                    )
                );
              }
            },
            elevation: 15,
            label: const Text(
              'Recommend',
              style: TextStyle(
                  fontFamily: 'opensans',
                  fontSize: 20,
                  fontWeight: FontWeight.normal
              ),
            ),
            icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 30)
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
          Padding(
            padding: EdgeInsets.only(top: 40, left: 10, right: 10, bottom: 30),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recipe Recommendations',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontFamily: 'opensans',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff4417810)),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Ingredients from your pantry and we\'ll recommend recipes created by our users!',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: 'opensans',
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                    )),
                //const Text('Enter the ingredients that you have', style: TextStyle(fontFamily: 'Raleway',fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: getIngredients(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                          padding: EdgeInsets.only(
                              left: 5, right: 5, top: 10, bottom: 10),
                          child: Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<String>.empty();
                              }
                              var matchingOptions = snapshot.data!
                                  .map<String>((item) => item['name'] ?? '')
                                  .where((String option) {
                                return option.contains(
                                    textEditingValue.text.toLowerCase());
                              }).toList();
                              if (matchingOptions.isEmpty) {
                                return [
                                  'No match found for \"${textEditingValue.text}\"'
                                ];
                              }
                              return matchingOptions;
                            },
                            onSelected: _onIngredientSelected,
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
                                            color: Color(0xff4417810)),
                                      ),
                                      hintText:
                                          'Start typing for suggestions...',
                                      hintStyle: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                      fontFamily: 'opensans',
                                      ),
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
                                            left: 10.0, right: 10), // Add horizontal padding
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
                                                contentPadding:EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                Wrap(
                  spacing: 8.0, // gap between adjacent chips
                  runSpacing: 4.0, // gap between lines
                  children: _selectedIngredientIds.map((String ingredientId) {
                    return Chip(
                      label: Text(
                        _ingredientNameToId.entries
                            .firstWhere((entry) => entry.value == ingredientId)
                            .key,
                        style: TextStyle(
                            fontFamily: 'opensans',
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xff4417810)),
                      ),
                      backgroundColor: Colors.white, //Color(0xff4417810),
                      deleteIcon: Icon(Icons.close),
                      deleteIconColor: const Color(0xff4417810),
                      onDeleted: () {
                        setState(() {
                          _selectedIngredientIds.remove(ingredientId);
                        });
                      },
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: const Color(0xff4417810), width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDuplicateIngredientToast(String ingredientName) {
    Fluttertoast.showToast(
      msg: 'Ingredient "$ingredientName" already added!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _onIngredientSelected(String selection) {
    final ingredientId = _ingredientNameToId[selection];
    if (ingredientId != null) {
      if (!_selectedIngredientIds.contains(ingredientId)) {
        setState(() {
          _selectedIngredientIds.add(ingredientId);
          _resetController.value = true;
        });
      } else {
        _showDuplicateIngredientToast(selection);
      }
    }
  }
}
