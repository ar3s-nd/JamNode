import 'package:flutter/material.dart';

class ImageCircle extends StatelessWidget {
  final String letter;
  final double circleRadius;
  final double fontSize;
  final List<Color> colors;
  Color letterColor = Colors.black;
  ImageCircle({
    super.key,
    required this.letter,
    required this.circleRadius,
    required this.fontSize,
    required this.colors,
    this.letterColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleRadius * 2,
      height: circleRadius * 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center, // Centers the text within the circle
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          color: letterColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
