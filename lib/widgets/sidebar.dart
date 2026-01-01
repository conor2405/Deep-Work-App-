import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          61, // just the right width to fit the close, minimize and maximize buttons.
      color: BlocProvider.of<SettingsBloc>(context).isDarkMode
          ? Colors.grey.shade800
          : Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 24),
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
              icon: Icon(Icons.public),
              onPressed: () => Navigator.pushNamed(context, '/worldMapPage')),
          SizedBox(height: 35),
          IconButton(
              icon: Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, '/profile')),
          SizedBox(height: 35),
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings')),
          Spacer(),
          IconButton(
              icon: Icon(Icons.feedback_outlined),
              onPressed: () => Navigator.pushNamed(context, '/feedback')),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
