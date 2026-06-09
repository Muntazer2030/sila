import 'package:flutter/material.dart';

class MainPageAddingCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const MainPageAddingCard({
    super.key,
    this.title = "",
    this.icon = Icons.add,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.alphaBlend(
        color.withValues(alpha: 0.05),
        Theme.of(context).colorScheme.surface,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
