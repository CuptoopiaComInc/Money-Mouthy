import 'package:flutter/material.dart';

class CategoriesRankingScreen extends StatefulWidget {
  const CategoriesRankingScreen({super.key});

  @override
  State<CategoriesRankingScreen> createState() =>
      _CategoriesRankingScreenState();
}

class _CategoriesRankingScreenState extends State<CategoriesRankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample category data with rankings
  final List<Map<String, dynamic>> _categoryStats = [
    {
      'name': 'Politics',
      'icon': Icons.how_to_vote,
      'color': const Color(0xFF4C5DFF),
      'totalPosts': 156,
      'totalEarnings': 2450.50,
      'averagePrice': 15.70,
      'topPost': 89.99,
      'trendingUp': true,
    },
    {
      'name': 'News',
      'icon': Icons.newspaper,
      'color': const Color(0xFF29CC76),
      'totalPosts': 134,
      'totalEarnings': 3200.25,
      'averagePrice': 23.88,
      'topPost': 149.99,
      'trendingUp': true,
    },
    {
      'name': 'Sports',
      'icon': Icons.sports_soccer,
      'color': const Color(0xFFC43DFF),
      'totalPosts': 98,
      'totalEarnings': 1890.75,
      'averagePrice': 19.29,
      'topPost': 79.99,
      'trendingUp': false,
    },
    {
      'name': 'Sex',
      'icon': Icons.favorite,
      'color': const Color(0xFFFF4081),
      'totalPosts': 87,
      'totalEarnings': 1456.80,
      'averagePrice': 16.74,
      'topPost': 59.99,
      'trendingUp': true,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': const Color(0xFFA06A00),
      'totalPosts': 76,
      'totalEarnings': 1123.45,
      'averagePrice': 14.78,
      'topPost': 49.99,
      'trendingUp': false,
    },
    {
      'name': 'Religion',
      'icon': Icons.church,
      'color': const Color(0xFF000000),
      'totalPosts': 65,
      'totalEarnings': 987.60,
      'averagePrice': 15.19,
      'topPost': 39.99,
      'trendingUp': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _byEarnings {
    var list = List<Map<String, dynamic>>.from(_categoryStats);
    list.sort((a, b) => b['totalEarnings'].compareTo(a['totalEarnings']));
    return list;
  }

  List<Map<String, dynamic>> get _byPosts {
    var list = List<Map<String, dynamic>>.from(_categoryStats);
    list.sort((a, b) => b['totalPosts'].compareTo(a['totalPosts']));
    return list;
  }

  List<Map<String, dynamic>> get _byTopPost {
    var list = List<Map<String, dynamic>>.from(_categoryStats);
    list.sort((a, b) => b['topPost'].compareTo(a['topPost']));
    return list;
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Categories Ranking',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF5159FF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF5159FF),
          tabs: const [
            Tab(text: 'By Earnings'),
            Tab(text: 'By Posts'),
            Tab(text: 'Top Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRankingList(_byEarnings, 'earnings'),
          _buildRankingList(_byPosts, 'posts'),
          _buildRankingList(_byTopPost, 'topPost'),
        ],
      ),
    );
  }

  Widget _buildRankingList(
    List<Map<String, dynamic>> categories,
    String sortBy,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final rank = index + 1;
        return _buildCategoryRankCard(category, rank, sortBy);
      },
    );
  }

  Widget _buildCategoryRankCard(
    Map<String, dynamic> category,
    int rank,
    String sortBy,
  ) {
    Color rankColor = Colors.grey;
    if (rank == 1) rankColor = Colors.amber;
    if (rank == 2) rankColor = Colors.grey[400]!;
    if (rank == 3) rankColor = Colors.orange[300]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border:
            rank <= 3
                ? Border.all(color: rankColor, width: 2)
                : Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Category Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: category['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category['icon'], color: category['color'], size: 28),
          ),

          const SizedBox(width: 16),

          // Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      category['trendingUp']
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: category['trendingUp'] ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildStatsRow(category, sortBy),
                const SizedBox(height: 8),
                _buildSecondaryStats(category, sortBy),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> category, String sortBy) {
    String mainStat = '';
    String mainLabel = '';

    switch (sortBy) {
      case 'earnings':
        mainStat = '\$${category['totalEarnings'].toStringAsFixed(2)}';
        mainLabel = 'Total Earnings';
        break;
      case 'posts':
        mainStat = '${category['totalPosts']}';
        mainLabel = 'Total Posts';
        break;
      case 'topPost':
        mainStat = '\$${category['topPost'].toStringAsFixed(2)}';
        mainLabel = 'Highest Post';
        break;
    }

    return Row(
      children: [
        Text(
          mainStat,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5159FF),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          mainLabel,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSecondaryStats(Map<String, dynamic> category, String sortBy) {
    return Row(
      children: [
        if (sortBy != 'posts') ...[
          Icon(Icons.article, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            '${category['totalPosts']} posts',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
        ],
        if (sortBy != 'earnings') ...[
          Icon(Icons.monetization_on, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            '\$${category['totalEarnings'].toStringAsFixed(0)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
        ],
        Icon(Icons.bar_chart, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          'Avg: \$${category['averagePrice'].toStringAsFixed(2)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
