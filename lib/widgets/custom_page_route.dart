
import 'package:flutter/material.dart';

class CustomPageRoute<T> extends MaterialPageRoute<T> {
  CustomPageRoute({ required WidgetBuilder builder, RouteSettings? settings }) 
    : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200); // Durée réduite

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // Utilise une transition en fondu pour une sensation de rapidité
    return FadeTransition(opacity: animation, child: child);
  }
}
