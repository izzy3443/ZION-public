import 'package:flutter/material.dart';
import 'package:zion3/theme.dart';

class CustomFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String heroTag;

  const CustomFloatingButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.heroTag = "circleIconBtn",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Themes.white0(context),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Themes.black0(context).withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor:
            Themes.white0(context), // or Themes.white0(context) if defined
        heroTag: heroTag,
        onPressed: onPressed,
        elevation: 0,
        child: Icon(
          icon,
          color: Themes.black0(context),
        ),
      ),
    );
  }
}
