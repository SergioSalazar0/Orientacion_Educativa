import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Placeholder shimmer para listas de cards mientras cargan datos.
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E2535)
          : const Color(0xFFE2E8F0),
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D3748)
          : const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: _buildShimmerCards(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildShimmerCards() {
    final cards = <Widget>[];
    for (int i = 0; i < itemCount; i++) {
      if (i > 0) {
        cards.add(const SizedBox(height: 12));
      }
      cards.add(const _ShimmerCard());
    }
    return cards;
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(radius: 28, backgroundColor: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 14, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 120, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
