

import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';

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
    return Flexible(
      child: Card(
        color: Color.alphaBlend(
          color.withValues(alpha: 0.05),
          Theme.of(context).colorScheme.surface,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          
          children: [
            Icon(icon, size: 40, color: color),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MainPageStatisticsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final int count;
  const MainPageStatisticsCard({
    super.key,
    this.title = "",
    this.icon = Icons.people,
    this.iconColor = Colors.black,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: white,
      shadowColor: Colors.grey[400],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: black,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "$count",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: black,
                            fontSize: 22,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: iconColor,
                child: Icon(icon, size: 40, color: white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

