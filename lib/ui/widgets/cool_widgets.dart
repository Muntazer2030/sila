import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const StatusChip({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), // 10% opacity background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

// Custom star rating row
class StarRating extends StatelessWidget {
  final double rating;
  const StarRating({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < fullStars) {
            return const Icon(Icons.star, color: Colors.amber, size: 16);
          } else if (index == fullStars && hasHalfStar) {
            return const Icon(Icons.star_half, color: Colors.amber, size: 16);
          } else {
            return const Icon(Icons.star_border, color: Colors.amber, size: 16);
          }
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}

class EditableStarRating extends StatefulWidget {
  final double initialRating;
  final Function(double) onChanged;

  const EditableStarRating({
    super.key,
    required this.initialRating,
    required this.onChanged,
  });

  @override
  State<EditableStarRating> createState() => _EditableStarRatingState();
}

class _EditableStarRatingState extends State<EditableStarRating> {
  late double currentRating;

  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                currentRating = index + 1.0;
              });
              widget.onChanged(currentRating);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0), // مسافة صغيرة بين النجوم
              child: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28, // حجم النجمة مناسب للماوس/اللمس
              ),
            ),
          );
        }),
        const SizedBox(width: 10),
        Text(
          currentRating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}