import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum AnimationType { opacity, translateY }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  const FadeAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween(
        AnimationType.opacity,
        Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
      )
      ..tween(
        AnimationType.translateY,
        Tween(begin: 30.0, end: 0.0),
        duration: const Duration(milliseconds: 500),
      );
    return PlayAnimationBuilder(
        delay: Duration(milliseconds: (delay).round()),
        duration: tween.duration,
        tween: tween,
        child: child,
        builder: (context, value, _) {
          return Opacity(
            opacity: value.get(AnimationType.opacity),
            child: Transform.translate(
                offset: Offset(0, value.get(AnimationType.translateY)),
                child: child),
          );
        });
  }
}
