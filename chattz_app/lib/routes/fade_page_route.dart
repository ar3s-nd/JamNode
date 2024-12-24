import 'package:flutter/material.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Offset beginOffset;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(1.0, 0.0),
    super.settings,
  }) : super(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}
