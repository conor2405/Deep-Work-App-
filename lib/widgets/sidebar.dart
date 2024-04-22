import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          61, // just the right width to fit the close, minimize and maximize buttons.
      color: Colors.grey.shade800,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.access_time_filled_rounded),
            onPressed: () => Navigator.pushNamed(context, '/'),
          ),
          SizedBox(height: 35),
          IconButton(
              icon: Icon(Icons.stacked_line_chart_sharp),
              onPressed: () => Navigator.pushNamed(
                  context, '/charts')), // Remove the trailing comma here

          SizedBox(height: 35),
          IconButton(
              icon: Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, '/profile')),
          SizedBox(height: 35),
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings')),
          SizedBox(height: 35),

          // Add more icons here if needed
        ],
      ),
    );
  }
}
