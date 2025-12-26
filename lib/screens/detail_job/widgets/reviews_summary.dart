import 'package:flutter/material.dart';

class ReviewsSummary extends StatelessWidget {
  final double _mean;
  final int _numReviews;

  const ReviewsSummary({
    super.key,
    required double mean,
    required int numReviews,
  }) : _mean = mean,
       _numReviews = numReviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingRow('Seller communication level', _mean),
        _buildRatingRow('Quality of delivery', _mean),
        _buildRatingRow('Value of delivery', _mean),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_numReviews reviews',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'See All',
              style: TextStyle(color: Colors.green, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingRow(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: Colors.black),
              const SizedBox(width: 4),
              Text(rating.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}