import 'package:flutter/material.dart';
import 'package:money_mouthy_two/screens/home_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<String> selectedCategories = [];
  bool showRanking = false;
  Map<String, int> categoryRankings = {};

  final List<Map<String, dynamic>> categories = [
    {'name': 'News', 'color': const Color(0xFF29CC76)},
    {'name': 'Politics', 'color': const Color(0xFF4C5DFF)},
    {'name': 'Sex', 'color': const Color(0xFFFF4081)},
    {'name': 'Entertainment', 'color': const Color(0xFFA06A00)},
    {'name': 'Sport', 'color': const Color(0xFFC43DFF)},
    {'name': 'Religion', 'color': const Color(0xFF000000)},
  ];

  void toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
        categoryRankings.remove(category);
      } else {
        selectedCategories.add(category);
        categoryRankings[category] = selectedCategories.length;
      }
    });
  }

  void showRankingView() {
    setState(() {
      showRanking = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text(
                'Skip for Now',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Title
              const Center(
                child: Text(
                  'Choose your categories of interest from the list below',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              const Center(
                child: Text(
                  'Don\'t miss out on trending news happening around the world, choose from our list of categories and share your stories',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Category buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories.map((category) {
                  final isSelected = selectedCategories.contains(category['name']);
                  return GestureDetector(
                    onTap: () => toggleCategory(category['name']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? category['color'] : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? category['color'] : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        category['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              if (!showRanking && selectedCategories.isNotEmpty) ...[
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: showRankingView,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: const Text(
                    'Show Ranking',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              
              // Ranking section
              if (showRanking && selectedCategories.isNotEmpty) ...[
                const SizedBox(height: 40),
                
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rank your categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Top most category is based on the number of categories selected. Tap any category to rank your preferred category.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Ranking list - Fixed order
                Column(
                  children: [
                    _buildRankingItem('News', const Color(0xFF29CC76), 5, 1, true),
                    _buildRankingItem('Politics', const Color(0xFF4C5DFF), 4, 2, false),
                    _buildRankingItem('Sex', const Color(0xFFFF4081), 3, 3, false),
                    _buildRankingItem('Entertainment', const Color(0xFFA06A00), 2, 4, false),
                    _buildRankingItem('Sport', const Color(0xFFC43DFF), 1, 5, false),
                    _buildRankingItem('Religion', const Color(0xFF000000), 0, 6, false),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
              
              if (!showRanking) const Spacer(),
              
              // Continue button (only show when not ranking or when ranking is complete)
              if (!showRanking || selectedCategories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C5DFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankingItem(String category, Color color, int stars, int rank, bool isTopRated) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Category pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          // Stars
          Row(
            children: List.generate(5, (starIndex) {
              return Icon(
                starIndex < stars ? Icons.star : Icons.star_border,
                color: starIndex < stars ? Colors.amber : Colors.grey.shade300,
                size: 16,
              );
            }),
          ),
          const SizedBox(width: 16),
          // Rank number
          Text(
            '$rank',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          // Top Rated text
          SizedBox(
            width: 60,
            child: Text(
              isTopRated ? 'Top Rated' : '',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 