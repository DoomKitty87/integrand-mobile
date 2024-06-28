import 'package:flutter/material.dart';

void animateWithSlideFromRight(BuildContext context, Widget child, Duration duration) {
  child = SafeArea(
    child: child
  );
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return child;
      },
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const Offset begin = Offset(1.0, 0.0);
        const Offset end = Offset.zero;
        final tween = Tween<Offset>(
          begin: begin,
          end: end,
        );
        final Animation<Offset> offsetAnimation = tween.animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ), 
  );
}