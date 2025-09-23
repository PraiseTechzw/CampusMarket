/// @Branch: Product Review Widget
///
/// Widget for displaying and managing product reviews
/// Includes rating display, review submission, and review list
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/repositories/firebase_repository.dart';

class ProductReviewWidget extends StatefulWidget {
  final String productId;
  final double? averageRating;
  final int reviewCount;

  const ProductReviewWidget({
    super.key,
    required this.productId,
    this.averageRating,
    this.reviewCount = 0,
  });

  @override
  State<ProductReviewWidget> createState() => _ProductReviewWidgetState();
}

class _ProductReviewWidgetState extends State<ProductReviewWidget> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  int _userRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reviews = await FirebaseRepository.getProductReviews(
        widget.productId,
      );
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading reviews: $e')));
      }
    }
  }

  Future<void> _submitReview() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit a review')),
      );
      return;
    }

    if (_userRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await FirebaseRepository.createProductReview(
        widget.productId,
        user.id,
        _userRating,
        _reviewController.text.trim(),
      );

      if (result != null) {
        _reviewController.clear();
        _userRating = 0;
        await _loadReviews();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit review')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting review: $e')));
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating Summary
        _buildRatingSummary(),
        const SizedBox(height: 16),

        // Review Submission Form
        _buildReviewForm(),
        const SizedBox(height: 24),

        // Reviews List
        _buildReviewsList(),
      ],
    );
  }

  Widget _buildRatingSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Star Rating Display
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.averageRating?.toStringAsFixed(1) ?? '0.0',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(5, (index) {
                      final rating = widget.averageRating ?? 0;
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 20,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.reviewCount} review${widget.reviewCount != 1 ? 's' : ''}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),

            // Rating Distribution
            if (widget.reviewCount > 0) _buildRatingDistribution(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(5, (index) {
        final rating = 5 - index;
        final count = _reviews.where((r) => r['rating'] == rating).length;
        final percentage = widget.reviewCount > 0
            ? count / widget.reviewCount
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$rating', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Icon(Icons.star, size: 12, color: Colors.orange),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text('$count', style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewForm() {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Please sign in to write a review',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a Review',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Star Rating Input
            Row(
              children: [
                const Text('Rating: '),
                ...List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _userRating = index + 1;
                      });
                    },
                    child: Icon(
                      index < _userRating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 32,
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Review Text
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share your experience with this product...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No reviews yet. Be the first to review this product!',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ..._reviews.map((review) => _buildReviewItem(review)),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final user = review['user'] as Map<String, dynamic>?;
    final rating = review['rating'] as int;
    final comment = review['comment'] as String;
    final createdAt = review['createdAt'] as Timestamp?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info and Rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user?['profileImageUrl'] != null
                      ? NetworkImage(user!['profileImageUrl'].toString())
                      : null,
                  child: user?['profileImageUrl'] == null
                      ? Text(
                          '${user?['firstName']?.toString().substring(0, 1) ?? 'U'}',
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?['firstName']?.toString() ?? 'Unknown'} ${user?['lastName']?.toString() ?? 'User'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                              size: 16,
                            );
                          }),
                          const SizedBox(width: 8),
                          if (createdAt != null)
                            Text(
                              _formatDate(createdAt.toDate()),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Review Comment
            if (comment.isNotEmpty)
              Text(comment, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
