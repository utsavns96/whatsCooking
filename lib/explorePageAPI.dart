import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'RecipeWebViewPage.dart';
import 'Base.dart';

/*
================================================================================
Explore page where the user is shown 20 random recipes,
and can search for recipes based on a query word.
================================================================================
 */

/*class explorePageAPI extends StatefulWidget {
  @override
  _explorePageAPIState createState() => _explorePageAPIState();
}*/

class explorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      body: explorePageAPI(),
    );
  }
}

class explorePageAPI extends StatefulWidget {
  static final ValueNotifier<bool> resetNotifier =
      ValueNotifier<bool>(false); // Moved resetNotifier here

  @override
  _explorePageAPIState createState() => _explorePageAPIState();
}

class _explorePageAPIState extends State<explorePageAPI> {
  List<dynamic> images = [];
  String apiId = '84f1a7c3';
  String apiKey = '7a5e7ebac78700130cd351870baca6ed';
  ScrollController _scrollController = new ScrollController();
  String? nextPageUrl;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  ValueNotifier<bool> _searchFocusNotifier = ValueNotifier<bool>(false);
  bool searchActive = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      _searchFocusNotifier.value = _searchFocusNode.hasFocus;
    });
    fetchDinnerRecipes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        searchActive ? fetchNextPage() : fetchMoreDinnerRecipes();
      }
    });
  }

  fetchDinnerRecipes() async {
    String mealType;
    var now = DateTime.now().hour;

    if (now >= 5 && now < 11) {
      mealType = 'Breakfast';
    } else if (now >= 11 && now < 14) {
      mealType = 'Lunch';
    } else if (now >= 14 && now < 17) {
      mealType = 'Snack';
    } else if (now >= 17 && now < 22) {
      mealType = 'Dinner';
    } else {
      mealType = 'Teatime';
    }

    var response = await http.get(Uri.parse(
        'https://api.edamam.com/api/recipes/v2?type=public&app_id=$apiId&app_key=$apiKey&mealType=$mealType&random=true'));
    var decodedData = jsonDecode(response.body);
    setState(() {
      images = decodedData['hits'];
      nextPageUrl = decodedData['_links']?['next']?['href'];
      searchActive = false;
    });
  }

  fetchMoreDinnerRecipes() async {
    print('fetchMoreDinnerRecipes');
    String mealType;
    var now = DateTime.now().hour;

    if (now >= 5 && now < 11) {
      mealType = 'Breakfast';
    } else if (now >= 11 && now < 14) {
      mealType = 'Lunch';
    } else if (now >= 14 && now < 17) {
      mealType = 'Snack';
    } else if (now >= 17 && now < 22) {
      mealType = 'Dinner';
    } else {
      mealType = 'Teatime';
    }

    var response = await http.get(Uri.parse(
        'https://api.edamam.com/api/recipes/v2?type=public&app_id=$apiId&app_key=$apiKey&mealType=$mealType&random=true'));
    var decodedData = jsonDecode(response.body);
    setState(() {
      images.addAll(decodedData['hits']);
      nextPageUrl = decodedData['_links']?['next']?['href'];
      searchActive = false;
    });
  }

  fetchSearchImages(String query) async {
    var response = await http.get(Uri.parse(
        'https://api.edamam.com/api/recipes/v2?type=public&q=$query&app_id=$apiId&app_key=$apiKey'));
    var decodedData = jsonDecode(response.body);
    setState(() {
      images = decodedData['hits'];
      nextPageUrl = decodedData['_links']?['next']?['href'];
      searchActive=true;
    });
  }

  fetchNextPage() async {
    print('fetchNextPage');
    if (nextPageUrl != null) {
      var response = await http.get(Uri.parse(nextPageUrl!));
      var decodedData = jsonDecode(response.body);
      setState(() {
        images.addAll(decodedData['hits']);
        nextPageUrl = decodedData['_links']?['next']?['href'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {


    return BaseWidget(
      body: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Explore Recipes',
            style: TextStyle(
              color: Color(0xff4417810),
              fontFamily: 'opensans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Stack(
          children:[
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (value) {
                            setState(() {
                              images = [];
                              fetchSearchImages(value);
                            });
                          },
                          focusNode: _searchFocusNode,
                          style: TextStyle(color: Colors.black, fontFamily: 'opensans'), // Set the text color
                          decoration: InputDecoration(
                            hintText: "Search recipes...",
                            hintStyle: TextStyle(color: Colors.grey, fontFamily: 'opensans'), // Set the hint text color
                            filled: true,
                            fillColor: Colors.white, // Set the fill color
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0), // Set the border radius
                              borderSide: BorderSide(color: Color(0xff4417810)), // Set the border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0), // Set the border radius when focused
                              borderSide: BorderSide(color: Color(0xff4417810), width: 2), // Set the border color when focused
                            ),
                            // Add the clear icon
                            suffixIcon: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _searchController,
                              builder: (BuildContext context, TextEditingValue value, Widget? child) {
                                return IconButton(
                                  icon: Icon(value.text.isEmpty ? Icons.search : Icons.clear),
                                  onPressed: () {
                                    if (value.text.isEmpty) {
                                      setState(() {
                                        images = [];
                                        fetchDinnerRecipes();
                                        //searchActive = false;
                                      });
                                    } else {
                                      _searchController.clear(); // Clear the text in the TextField
                                      _searchFocusNode.requestFocus(); // Request focus to bring up the keyboard
                                      setState(() {
                                        images = [];
                                        fetchSearchImages(value.text);
                                        //searchActive = true;
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        child: Text('Cancel', style: TextStyle(fontFamily: 'opensans', color: Color(0xff4417810)),),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            images = [];
                            //searchActive = false;
                            fetchDinnerRecipes();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Material(
                      child: Container(
                        padding: EdgeInsets.only(top: 5), //Change top padding here only
                        child: Stack(children: [
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10), //do not add top padding here
                            child: RefreshIndicator(
                                  onRefresh: () async {
                                    // Call your refresh function here.
                                    // For example, you might want to fetch new data from the API:
                                    searchActive? await fetchSearchImages(_searchController.text) : await fetchDinnerRecipes();
                                  },
                                  child: GridView.builder(
                                    controller: _scrollController,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 2,
                                      mainAxisSpacing: 2,
                                    ),
                                    itemCount: images.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          print('Image at index $index was tapped');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RecipeWebViewPage(
                                                  recipeUrl: images[index]['recipe']['url'],
                                                  recipe_id: images[index]['_links']['self']
                                                  ['href'] // Get the recipe ID from the URL,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10.0),
                                            child: Stack(
                                              children: <Widget>[
                                                Image.network(images[index]['recipe']['images']
                                                ['REGULAR']['url']),
                                                Align(
                                                  alignment: Alignment.bottomCenter,
                                                  child: FractionallySizedBox(
                                                    heightFactor:
                                                    0.3, // Cover the bottom third of the image
                                                    widthFactor:
                                                    1.0, // Cover the entire width of the image
                                                    child: Container(
                                                      color: Colors.black.withOpacity(0.6),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 8.0,
                                                                vertical: 4.0), // Reduced padding
                                                            child: Text(
                                                              images[index]['recipe']['label'],
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 13,
                                                                fontFamily: 'opensans',
                                                              ),
                                                              textAlign: TextAlign.center,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 8.0,
                                                                vertical: 4.0), // Reduced padding
                                                            child: Text(
                                                              '${images[index]['recipe']['source']}', // Display the source
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 10,
                                                                fontFamily: 'opensans',
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: _searchFocusNotifier,
                            builder: (BuildContext context, bool hasFocus, Widget? child) {
                              return hasFocus
                                  ? Container(
                                color: Colors.black.withOpacity(0.5),
                                // child: Center(
                                //   child: CircularProgressIndicator(),
                                // ),
                              )
                                  : SizedBox.shrink();
                            },
                          ),
                        ],)
                      ),

                    )),
              ],
            ),
          ]
        ),
      ),
    );
  }
}
