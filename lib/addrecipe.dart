import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart'; // Added this line
import 'CreatedRecipesPage.dart';
import 'Base.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

void main() async {
  runApp(MaterialApp(
    home: AddRecipePage(),
  ));
}

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  late SharedPreferences prefs;
  String? email;
  String? uid;

  File? _image;
  final ImagePicker picker = ImagePicker();

  Future getImage() async {
    showDialog(
        context: this.context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choose an option',
                style: TextStyle(fontFamily: 'opensans')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text("Pick Image from Gallery",
                        style: TextStyle(fontFamily: 'opensans')),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      setState(() {
                        if (pickedFile != null) {
                          _image = File(pickedFile.path);
                        } else {
                          print('No image selected.');
                        }
                      });
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Text("Take a Picture",
                        style: TextStyle(fontFamily: 'opensans')),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.camera);
                      setState(() {
                        if (pickedFile != null) {
                          _image = File(pickedFile.path);
                        } else {
                          print('No image selected.');
                        }
                      });
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

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
  }

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _tagsController = TextEditingController();
  List<String> _selectedIngredients = [];
  Map<String, String> _ingredientQuantities = {};
  Map<String, String> _selectedIngredientNames = {};
  final ValueNotifier<bool> _resetController = ValueNotifier<bool>(false);
  Map<String, String> _ingredientNameToId = {};
  List<TextEditingController> _instructionControllers = [];
  List<String> _selectedTags = [];
  final List<String> _tags = [
    "Vegetarian",
    "Vegan",
    "Non-vegetarian",
    "Gluten-free",
    "Low sodium",
    "Breakfast",
    "Lunch",
    "Dinner",
    "Dessert"
  ];

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
  Widget build(BuildContext context) {
    return BaseWidget(
        body: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Add Recipe',
                style: TextStyle(
                    color: Color(0xff4417810),
                    fontFamily: 'opensans',
                    fontWeight: FontWeight.w600),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text('Recipe Title', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    // ),
                    Container(
                      height: MediaQuery.of(context).size.height *
                          0.08, // 10% of screen height
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Enter recipe title',
                          labelStyle: TextStyle(
                              color: Color(0xff4417810),
                              fontFamily: 'opensans'), // Change the color here
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff4417810),
                                width: 3.0), // Change the border color here
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff4417810),
                                width:
                                    2.0), // Change the border color when focused
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text('Cook Time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    // ),
                    Container(
                      height: MediaQuery.of(context).size.height *
                          0.08, // 10% of screen height
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _cookTimeController,
                        decoration: InputDecoration(
                          labelText: 'Enter cook time in minutes',
                          labelStyle: TextStyle(
                              color: Color(0xff4417810),
                              fontFamily: 'opensans'), // Change the color here
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff4417810),
                                width: 3.0), // Change the border color here
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff4417810),
                                width:
                                    2.0), // Change the border color when focused
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter cook time';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Ingredients',
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'opensans',
                              fontWeight: FontWeight.normal,
                              color: Colors.black)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      //height: MediaQuery.of(context).size.height * 0.2, // 10% of screen height
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: getIngredients(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.hasData) {
                            return Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Autocomplete<String>(
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text == '') {
                                      return const Iterable<String>.empty();
                                    }
                                    var matchingOptions = snapshot.data!
                                        .map<String>(
                                            (item) => item['name'] ?? '')
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
                                    return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.075,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        child: TextField(
                                          controller:
                                              fieldTextEditingController,
                                          focusNode: fieldFocusNode,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide(
                                                  color:
                                                      const Color(0xff4417810)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              borderSide: BorderSide(
                                                  color: Color(0xff4417810),
                                                  width:
                                                      2), // Set the border color to blue when tapped
                                            ),
                                            hintText:
                                                'Start typing to add ingredients...',
                                            hintStyle: TextStyle(
                                                fontSize: 15.0,
                                                color: Color(0xff4417810),
                                                fontFamily: 'opensans',
                                                fontWeight: FontWeight.normal),
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
                                            filled: false,
                                            fillColor: Colors
                                                .white, // Set the background color to green
                                            focusColor: Colors.green,
                                          ),
                                        ));
                                  },
                                  optionsViewBuilder: (BuildContext context,
                                      AutocompleteOnSelected<String> onSelected,
                                      Iterable<String> options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        elevation: 10.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                5)), // Rounded corners
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              30, // Subtract the desired padding from the screen width
                                          child: Container(
                                            color:
                                                Colors.white60, // Change color
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10.0,
                                                  right:
                                                      10), // Add horizontal padding
                                              child: ListView.builder(
                                                itemCount: options.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  final String option =
                                                      options.elementAt(index);
                                                  return GestureDetector(
                                                    onTap: () {
                                                      onSelected(option);
                                                    },
                                                    child: ListTile(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 0,
                                                              horizontal: 16),
                                                      visualDensity:
                                                          VisualDensity(
                                                              vertical: -4),
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

                    ..._selectedIngredientNames.entries.map((entry) => Card(
                          color: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                                //SizedBox(width: 8.0),
                                Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.05, // 10% of screen height
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: TextFormField(
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                          left: 10,
                                          right: 10),
                                      labelText: 'Quantity',
                                      labelStyle: TextStyle(
                                          color: Color(0xff4417810),
                                          fontSize: 15,
                                          fontFamily:
                                          'opensans'), // Change the color here
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xff4417810),
                                            width:
                                            3.0), // Change the border color here
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xff4417810),
                                            width:
                                            2.0), // Change the border color when focused
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        _ingredientQuantities[entry.value] =
                                            value;
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Color(0xff4417810)),
                                  onPressed: () {
                                    setState(() {
                                      _selectedIngredients.remove(entry.key);
                                      _ingredientQuantities.remove(entry.key);
                                      _selectedIngredientNames
                                          .remove(entry.key);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Instructions',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'opensans')),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _instructionControllers.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          child: ListTile(
                            title: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _instructionControllers[index].text =
                                      'Step ${index + 1} clicked';
                                });
                              },
                              child: TextFormField(
                                controller: _instructionControllers[index],
                                decoration: InputDecoration(
                                  labelText:
                                      "Step " + (index + 1).toString() + ":",
                                  labelStyle: TextStyle(
                                      color: _instructionControllers[index]
                                              .text
                                              .contains('clicked')
                                          ? Colors.green
                                          : const Color(0xff4417810),
                                      fontFamily: 'opensans'),
                                ),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete,
                                  color: const Color(0xff4417810)),
                              onPressed: () {
                                setState(() {
                                  _instructionControllers.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height *
                            0.08, // 10% of screen height
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.all(8),
                        child: OutlinedButton(
                          onPressed: _addInstructionStep,
                          child: const Text(
                            'Add Step',
                            style: TextStyle(
                                color: const Color(0xff4417810),
                                fontSize: 18,
                                fontFamily:
                                    'opensans'), // Change the text color here
                          ),
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: const Color(
                                      0xff4417810)), // Change the stroke color here
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      5.0)) // Change the background color here
                              ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Tags',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'opensans')),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: MultiSelectDialogField(
                        items: _tags
                            .map((tag) => MultiSelectItem<String>(tag, tag))
                            .toList(),
                        title: Text(
                          'Tags',
                          style: TextStyle(
                              color: Color(0xff4417810),
                              fontFamily: 'opensans'),
                        ),
                        selectedColor: Color(0xff4417810),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Color(0xff4417810)),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        buttonIcon: Icon(Icons.arrow_drop_down),
                        buttonText: Text('Please choose one or more',
                            style: TextStyle(fontFamily: 'opensans')),
                        onConfirm: (values) {
                          _selectedTags = values;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Recipe Image',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'opensans')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200, // or any other size
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _image == null
                                ? const Color.fromRGBO(200, 200, 200, 1)
                                : const Color.fromRGBO(
                                    200, 200, 200, 0), // Set border color
                            width: 3.0, // Set border width
                          ),
                          borderRadius:
                              BorderRadius.circular(10.0), // Set border radius
                        ),
                        child: _image == null
                            ? const Center(
                                child: Text('No image selected',
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontFamily: 'opensans')))
                            : Image.file(_image!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            0.06, // 10% of screen height
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: OutlinedButton(
                          onPressed: getImage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: const Color(0xff4417810),
                                width: 2.0), // border color and width
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                _image == null ? Icons.add : Icons.edit,
                                color: const Color(0xff4417810),
                              ), // This is the upload icon
                              const SizedBox(
                                  width:
                                      5), // Give some spacing between the icon and the text
                              Text(
                                _image == null ? 'Add Image' : 'Change Image',
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xff4417810),
                                    fontFamily: 'opensans'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height *
                          0.08, // 10% of screen height
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color(0xff4417810), // foreground
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.file_upload), // This is the upload icon
                            SizedBox(
                                width:
                                    5), // Give some spacing between the icon and the text
                            Text('Submit Recipe',
                                style: TextStyle(
                                    fontSize: 18, fontFamily: 'opensans')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  void _addInstructionStep() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  Future<void> _submitForm() async {
    // Check if all fields are filled
    if (_titleController.text.trim().isEmpty ||
        _cookTimeController.text.trim().isEmpty ||
        _ingredientQuantities.isEmpty ||
        _ingredientQuantities.values.any((quantity) => quantity.trim().isEmpty) ||
        _instructionControllers.any((controller) => controller.text.trim().isEmpty) ||
        _selectedTags.isEmpty ||
        _image == null) {
      // If any field is not filled, show a toast message
      Fluttertoast.showToast(
          msg: "Please fill in all fields",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
    Fluttertoast.showToast(
        msg: "Submitting Recipe. Please wait...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    if (_formKey.currentState!.validate()) {
      String imageUrl = 'https://via.placeholder.com/150'; // default image URL
      if (_image != null) {
        // Create a reference to the location you want to upload to in Firebase Storage
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('recipes/${basename(_image!.path)}');

        // Upload the file to Firebase Storage
        UploadTask uploadTask = storageReference.putFile(_image!);

        // Get the download URL
        final TaskSnapshot downloadUrl = (await uploadTask);
        imageUrl = await downloadUrl.ref.getDownloadURL();
      }
      FirebaseFirestore.instance
          .collection('Recipes_test')
          .add({
            'title': _titleController.text,
            'cooktime': int.parse(_cookTimeController.text),
            'ingredientIDs': _selectedIngredientNames.keys.toList(),
            'ingredients': _ingredientQuantities,
            'instructions': _instructionControllers
                .map((controller) => controller.text)
                .toList(),
            'tags': _selectedTags,
            'approved': false,
            'createdBy': uid,
            'image': imageUrl,
            'rating': {},
          })
          .then((value) => {
                print("Recipe Added"),
                _titleController.clear(),
                _cookTimeController.clear(),
                _tagsController.clear(),
                _instructionControllers
                    .forEach((controller) => controller.clear()),
                setState(() {
                  _selectedIngredients.clear();
                  _ingredientQuantities.clear();
                  _selectedIngredientNames.clear();
                  _selectedTags.clear();
                  _image = null;
                }),
                //Dialog to show recipe added successfully
        showDialog(
          context: this.context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Recipe Submitted',
                  style: TextStyle(fontFamily: 'opensans')),
              content: Text(
                  'Your recipe has been submitted for review. Once it has been approved by our moderation team, it will be available for other users to view.'
                      '\n\nYou can check the status of your recipe in Profile > My Recipes.'
                      '\n\nYou can click on the button below to see all the recipes you have submitted.'
                      '\n\n\nThank you for contributing to our community!',
                  style: TextStyle(fontFamily: 'opensans')),
              actions: <Widget>[
                TextButton(
                  child: Text('See my Recipes',
                      style: TextStyle(fontFamily: 'opensans', color: Color(0xff4417810))),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            CreatedRecipesPage(), // Replace with your CreatedRecipesPage
                      ),
                    );
                  },
                ),
                TextButton(
                  child: Text('Close',
                      style: TextStyle(fontFamily: 'opensans', color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop(); // This line closes the dialog
                  },
                ),
              ],
            );
          },
        )
              })
          .catchError((error) => print("Failed to add recipe: $error"));
    }
  }

  void _onIngredientSelected(String selection) {
    final ingredientId = _ingredientNameToId[selection];
    if (ingredientId != null) {
      if (!_selectedIngredients.contains(ingredientId)) {
        setState(() {
          // _selectedIngredients.add(ingredientId);
          _selectedIngredientNames[ingredientId] = selection;
          _resetController.value = true;
        });
      } else {
        _showDuplicateIngredientToast(selection);
      }
    }
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
}
