import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartgrocery/addrecipe.dart';
import 'package:smartgrocery/explorePageAPI.dart';
import 'package:smartgrocery/profile.dart';

import 'addrecipe.dart';
import 'ingredientsSelectionSearch.dart';
import 'main.dart';

class BaseWidget extends StatefulWidget {
  final Widget body;
  BaseWidget({required this.body});

  @override
  _BaseWidgetState createState() => _BaseWidgetState();
}

class _BaseWidgetState extends State<BaseWidget> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipePage()),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => explorePageAPI()),
          );
          break; // <-- And this
        case 2:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => home(title: 'smartGrocery',)),
                (Route<dynamic> route) => false,
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => IngredientsSelection()),
          );
          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed appBar
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedLabelStyle: TextStyle(fontFamily: 'opensans'),
        selectedLabelStyle: TextStyle(fontFamily: 'opensans'),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ), // <-- And this
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Recommend',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff4417810),
        unselectedItemColor: const Color(0xff4417810),
        onTap: _onItemTapped,
      ),
    );
  }
}
