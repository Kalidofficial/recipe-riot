import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'manageaccount.dart';
import 'about.dart';
import 'recipe_detail.dart';
import 'spice_chat.dart';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  final TextEditingController _ingredientController = TextEditingController();
  List<String> ingredients = [];
  List<Map<String, dynamic>> recipeList = [];
  ScrollController _scrollController = ScrollController();
  int offset = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUser();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void getUser() {
    user = _auth.currentUser;
    setState(() {});
  }

  void addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        ingredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ingredient added!'),
      ));
    }
  }

  void clearIngredients() {
    setState(() {
      ingredients.clear();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent &&
        !isLoading) {
      fetchRecipes();
    }
  }

  Future<void> fetchRecipes() async {
    if (ingredients.isNotEmpty && !isLoading) {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(Uri.parse(
          'https://api.spoonacular.com/recipes/findByIngredients?ingredients=${ingredients.join(",")}&number=10&offset=$offset&apiKey=6a87dc977e6e4703ae43fcf973e43fd7'));

      if (response.statusCode == 200) {
        setState(() {
          List<Map<String, dynamic>> newRecipes = List<Map<String, dynamic>>.from(
              json.decode(response.body).map((recipe) => {
                'title': recipe['title'],
                'id': recipe['id'],
                'image': recipe['image']
              }));
          recipeList.addAll(newRecipes);
          offset += 10;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load recipes');
      }
    }
  }

  void clearRecipes() {
    setState(() {
      recipeList.clear();
      offset = 0;
    });
  }

  void logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/auth');
  }

  void showMenuOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuOption(
                title: 'Manage account',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageAccountPage()),
                  );
                },
              ),
              _buildMenuOption(
                title: 'About us',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutPage()),
                  );
                },
              ),
              _buildMenuOption(
                title: 'Logout',
                onTap: () {
                  logout();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({required String title, required VoidCallback onTap}) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        bool isHovered = false;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                color: isHovered ? Colors.red : Colors.black,
                fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: onTap,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Recipe Riot'),
        backgroundColor: Colors.red.shade800,
        actions: [
          IconButton(
            icon: Icon(Icons.message, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SpiceChat(receiverId: '',)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: showMenuOptions,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/images/hbg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _ingredientController,
                  decoration: InputDecoration(
                    labelText: 'Enter an ingredient',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: addIngredient,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: ingredients.map((ingredient) {
                    return Chip(
                      label: Text(
                        ingredient,
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.white54,
                      onDeleted: () {
                        setState(() {
                          ingredients.remove(ingredient);
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: fetchRecipes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade800,
                      ),
                      child: Text(
                        'Explore Recipes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: clearRecipes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade800,
                      ),
                      child: Text(
                        'Clear Recipes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Recipes:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: recipeList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailPage(
                                recipeTitle: recipeList[index]['title'],
                                recipeId: recipeList[index]['id'],
                                imageUrl: recipeList[index]['image'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  recipeList[index]['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        'Image not available',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  color: Colors.white70,
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    recipeList[index]['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
