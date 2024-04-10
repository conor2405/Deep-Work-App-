import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget desktopLayout;

  const ResponsiveLayout(
      {Key? key, required this.mobileLayout, required this.desktopLayout})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile layout
          return mobileLayout;
        } else {
          // Desktop layout
          return desktopLayout;
        }
      },
    );
  }
}
