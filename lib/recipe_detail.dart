import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeDetailPage extends StatefulWidget {
  final int recipeId;
  final String recipeTitle;
  final String imageUrl;

  RecipeDetailPage({
    required this.recipeId,
    required this.recipeTitle,
    required this.imageUrl,
  });

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Map<String, dynamic>? recipeDetails;
  bool showIngredients = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    final response = await http.get(Uri.parse(
        'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=6a87dc977e6e4703ae43fcf973e43fd7'));

    if (response.statusCode == 200) {
      setState(() {
        recipeDetails = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load recipe details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeTitle),
        backgroundColor: Colors.red.shade800, //Change the AppBar color
      ),
      body: recipeDetails == null
          ? Center(child: CircularProgressIndicator())
          : Container(
        width: double.infinity, // Set width to infinity
        height: double.infinity, // Set height to infinity
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/hbg.jpg'), // Background image
            fit: BoxFit.cover, // Cover the entire area
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image with 3D Effect
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4), // Shadow position
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    widget.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Toggle Capsules for Ingredients and Instructions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showIngredients = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: showIngredients ? Colors.red.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade800, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            "Ingredients",
                            style: TextStyle(
                              color: showIngredients ? Colors.white : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showIngredients = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: !showIngredients ? Colors.red.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade800, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            "Instructions",
                            style: TextStyle(
                              color: !showIngredients ? Colors.white : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Conditional Display of Ingredients or Instructions
              if (showIngredients) ...[
                Text(
                  "Ingredients:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade800, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...List<Widget>.from(recipeDetails!['extendedIngredients']
                          .map((ingredient) => Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: Colors.red.shade800),
                          SizedBox(width: 8),
                          Expanded(child: Text(ingredient['original'])),
                        ],
                      ))),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  "Instructions:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade800, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...List<Widget>.from(recipeDetails!['instructions']
                          .split('. ')
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key + 1; // Numbering starts from 1
                        String instruction = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text("$index. $instruction"),
                        );
                      })),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20),

              // Additional Details
              Text(
                "Preparation Time: ${recipeDetails!['readyInMinutes']} minutes",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "Servings: ${recipeDetails!['servings']}",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
