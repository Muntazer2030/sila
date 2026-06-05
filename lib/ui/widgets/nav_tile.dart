

import 'package:flutter/material.dart';
import 'package:sila/const/colors.dart';

class NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isCompact; // New parameter
  final VoidCallback onTap;
  const NavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.isActive,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If sidebar is collapsed (compact), show a centered icon only
    if (isCompact) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: isActive
          ? BoxDecoration(
              color: c2,
              borderRadius: BorderRadius.circular(10),
            )
          : null,
        child: IconButton(
          
          onPressed: onTap,
          icon: Icon(
            icon,
            color: isActive
                ? white
                : c2,
          ),
          tooltip: title, // Show text on hover
        ),
      );
    }

    // Normal full width tile
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: isActive
          ? BoxDecoration(
              color: c2,
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isActive
              ? white
              : c2,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive
                ? white
                : c2,
            fontWeight:  FontWeight.bold ,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
