import 'package:flutter/material.dart';
import '../services/post_service.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isTablet;
  final VoidCallback? onLike;
  final VoidCallback? onPurchase;
  final VoidCallback? onView;

  const PostCard({
    super.key,
    required this.post,
    this.isTablet = false,
    this.onLike,
    this.onPurchase,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPaidPost = post.price > 0;
    final bool hasAccess = post.isPaid || !isPaidPost;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: isTablet ? 20 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isTablet ? 28 : 24,
                  backgroundColor: const Color(0xFF5159FF),
                  child: Text(
                    post.author.split(' ').map((e) => e[0]).take(2).join(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 18 : 16,
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            post.timeAgo,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                          if (post.category.isNotEmpty) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isTablet ? 14 : 12,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5159FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                post.category,
                                style: TextStyle(
                                  color: const Color(0xFF5159FF),
                                  fontSize: isTablet ? 12 : 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Price badge
                if (isPaidPost)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 12 : 10,
                      vertical: isTablet ? 8 : 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasAccess 
                            ? [Colors.green, Colors.green.shade600]
                            : [const Color(0xFF5159FF), const Color(0xFF4146CC)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasAccess ? Icons.check_circle : Icons.monetization_on,
                          color: Colors.white,
                          size: isTablet ? 18 : 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasAccess ? 'Owned' : post.formattedPrice,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Title (if exists)
          if (post.title != null && post.title!.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 20 : 16,
                0,
                isTablet ? 20 : 16,
                isTablet ? 12 : 8,
              ),
              child: Text(
                post.title!,
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 20 : 16,
              0,
              isTablet ? 20 : 16,
              isTablet ? 16 : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAccess 
                      ? post.content
                      : '${post.content.substring(0, post.content.length > 100 ? 100 : post.content.length)}${post.content.length > 100 ? '...' : ''}',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  maxLines: hasAccess ? null : 3,
                  overflow: hasAccess ? null : TextOverflow.ellipsis,
                ),
                
                // Tags
                if (post.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: post.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: isTablet ? 12 : 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // Blur overlay for paid posts
          if (isPaidPost && !hasAccess)
            Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.9),
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.lock,
                      size: isTablet ? 40 : 32,
                      color: const Color(0xFF5159FF),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      'Premium Content',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5159FF),
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Text(
                      'Purchase to read full content',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                // Like button
                _buildActionButton(
                  icon: Icons.favorite_border,
                  label: '${post.likes}',
                  onTap: onLike,
                  color: Colors.red,
                ),
                SizedBox(width: isTablet ? 24 : 16),
                
                // Comments button
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: '${post.comments}',
                  onTap: () {},
                  color: Colors.blue,
                ),
                SizedBox(width: isTablet ? 24 : 16),
                
                // Views
                _buildActionButton(
                  icon: Icons.visibility_outlined,
                  label: '${post.views}',
                  onTap: onView,
                  color: Colors.grey,
                  isClickable: false,
                ),
                
                const Spacer(),
                
                // Purchase button for paid posts
                if (isPaidPost && !hasAccess)
                  ElevatedButton(
                    onPressed: onPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5159FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isTablet ? 12 : 8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Buy ${post.formattedPrice}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool isClickable = true,
  }) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isTablet ? 20 : 18,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 14 : 12,
          ),
        ),
      ],
    );

    if (isClickable && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }
    
    return child;
  }
} 