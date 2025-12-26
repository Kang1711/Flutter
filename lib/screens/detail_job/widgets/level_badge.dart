import 'package:flutter/material.dart';

class LevelBadge extends StatelessWidget {
  final int level;

  const LevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Level $level',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          _diamond(true),
          _diamond(level >= 2),
          _diamond(level >= 3),
        ],
      ),
    );
  }

  Widget _diamond(bool active) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Transform.rotate(
        angle: 0.785398,
        child: Icon(
          Icons.square,
          size: 10,
          color: active ? Colors.black : Colors.black26,
        ),
      ),
    );
  }
}