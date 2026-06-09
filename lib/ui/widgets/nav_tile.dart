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
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
            color: isActive ? white : c2,
          ),
          tooltip: title, // Show text on hover
        ),
      );
    }

    // Normal full width tile
    // THE FIX: Replaced ListTile with a custom Row to prevent animation crashes,
    // while perfectly preserving your colors and styling!
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: isActive
          ? BoxDecoration(
              color: c2,
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      // Wrapping InkWell in Material ensures the ripple effect works properly over the background color
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? white : c2,
                  size: 24,
                ),
                const SizedBox(width: 16), // Space between icon and text
                
                // THE SHIELD: Expanded allows the text to safely disappear as the sidebar shrinks
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? white : c2,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1, 
                    overflow: TextOverflow.clip, // Silently clips the text during the transition
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