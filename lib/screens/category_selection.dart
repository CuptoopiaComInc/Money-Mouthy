import 'package:flutter/material.dart';
import 'package:money_mouthy_two/screens/home_screen.dart';
import '../services/category_ranking_service.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<String> selectedCategories = [];
  bool showRanking = false;
  Map<String, int> categoryRankings = {};
  List<Map<String, dynamic>> rankedCategories = [];
  bool isLoading = true;

  final List<Map<String, dynamic>> categories = [
    {'name': 'News', 'color': const Color(0xFF29CC76)},
    {'name': 'Politics', 'color': const Color(0xFF4C5DFF)},
    {'name': 'Sex', 'color': const Color(0xFFFF4081)},
    {'name': 'Entertainment', 'color': const Color(0xFFA06A00)},
    {'name': 'Sports', 'color': const Color(0xFFC43DFF)},
    {'name': 'Religion', 'color': const Color(0xFF000000)},
  ];

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    try {
      final rankings = await CategoryRankingService.loadRankings();
      final ranked = await CategoryRankingService.getRankedCategories();

      if (mounted) {
        setState(() {
          categoryRankings = rankings;
          rankedCategories = ranked;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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

  Future<void> _updateCategoryRank(String categoryName, int newRank) async {
    try {
      await CategoryRankingService.updateCategoryRank(categoryName, newRank);
      await _loadRankings(); // Reload to get updated rankings

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$categoryName ranking updated!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update ranking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
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
                  children:
                      categories.map((category) {
                        final isSelected = selectedCategories.contains(
                          category['name'],
                        );
                        return GestureDetector(
                          onTap: () => toggleCategory(category['name']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? category['color']
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? category['color']
                                        : Colors.grey.shade300,
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text(
                      'Show Ranking',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                // Ranking section - Always show ranking
                if (showRanking) ...[
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
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dynamic ranking list
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children:
                          rankedCategories.map((category) {
                            return _buildRankingItem(
                              category['name'],
                              Color(category['color']),
                              category['stars'],
                              category['rank'],
                              category['rank'] == 1,
                            );
                          }).toList(),
                    ),

                  const SizedBox(height: 40),
                ],

                if (!showRanking) const SizedBox(height: 24),

                // Continue button (only show when not ranking or when ranking is complete)
                if (!showRanking || selectedCategories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
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
      ),
    );
  }

  Widget _buildRankingItem(
    String category,
    Color color,
    int stars,
    int rank,
    bool isTopRated,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
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
              return GestureDetector(
                onTap: () {
                  final newRank =
                      6 - starIndex; // 5 stars = rank 1, 1 star = rank 5
                  _updateCategoryRank(category, newRank);
                },
                child: Icon(
                  starIndex < stars ? Icons.star : Icons.star_border,
                  color:
                      starIndex < stars ? Colors.amber : Colors.grey.shade300,
                  size: 18,
                ),
              );
            }),
          ),
          const SizedBox(width: 16),
          // Rank adjustment buttons
          Column(
            children: [
              GestureDetector(
                onTap:
                    rank > 1
                        ? () => _updateCategoryRank(category, rank - 1)
                        : null,
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: rank > 1 ? Colors.blue : Colors.grey[300],
                  size: 20,
                ),
              ),
              Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap:
                    rank < 6
                        ? () => _updateCategoryRank(category, rank + 1)
                        : null,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: rank < 6 ? Colors.blue : Colors.grey[300],
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Top Rated text
          SizedBox(
            width: 60,
            child: Text(
              isTopRated ? 'Top Rated' : '',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
