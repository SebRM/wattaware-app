import 'package:flutter/material.dart';

// The design of the enheder and elpriser pages with gradient etc.
class PageDesign extends StatelessWidget {
  final Widget child;

  const PageDesign({super.key, required this.child});

  // Builds the UI with the gradient in the top
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient
        OverflowBox(
          alignment: Alignment.topCenter,
          minWidth: 0,
          minHeight: 0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Container(
            width: MediaQuery.of(context).size.width * 2,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xffffffff), Color(0xffffffff), Color(0xff0f4472), Color(0xff0f4472), Color(0xff0f4472)],
                center: Alignment(0.0, 1.05),
                radius: 2.1,
              ),
            ),
          ),
        ),
        // App title
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(
            left: 12,
            top: 32,
          ),
          child: Image.asset(
            'assets/logo.png',
            height: 70,
          ),
        ),
        // Contains main page UI under the app title
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
          child: child,
        ),
      ],
    );
  }
}
