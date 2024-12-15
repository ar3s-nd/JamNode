import 'package:flutter/material.dart';

class ImageCircle extends StatelessWidget {
  final String letter;
  final double circleRadius;
  final double fontSize;
  final List<Color> colors;
  const ImageCircle(
      {super.key,
      required this.letter,
      required this.circleRadius,
      required this.fontSize,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.tealAccent.shade200, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: circleRadius,
        backgroundColor: Colors.transparent,
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
