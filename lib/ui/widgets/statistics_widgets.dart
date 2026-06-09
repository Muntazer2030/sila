import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final int count;
  final VoidCallback? action;
  final bool isSelected;
  const StatisticsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.count,
    this.action,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Card(
        color: isSelected
            ? Color.alphaBlend(
                iconColor.withValues(alpha: 0.05),
                Theme.of(context).colorScheme.surface,
              )
            : white,

        shadowColor: Colors.grey.withValues(alpha: 0.4),
        elevation: 2,
        clipBehavior: Clip
            .antiAlias, // Ensures internal components don't bleed out of borders
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isSelected
              ? BorderSide(color: iconColor, width: 0)
              : BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              // 1. TEXT SECTION
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // scaleDown prevents the text from getting bigger than its max fontSize,
                    // but allows it to shrink gracefully if the screen gets tight.
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? iconColor : black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "$count",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? iconColor : black,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // 2. ICON SECTION
              Flexible(
                flex: 2,
                // AspectRatio guarantees the background container is ALWAYS a perfect square
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // LayoutBuilder dynamically reads the container size
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Center(
                          child: Icon(
                            icon,
                            // Icon scales automatically to 50% of its container's size
                            size: constraints.maxWidth * 0.7,
                            color: white,
                          ),
                        );
                      },
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
}
