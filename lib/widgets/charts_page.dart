import 'package:deep_work/widgets/sidebar.dart';
import 'package:flutter/material.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Sidebar(),
            Expanded(
              child: Center(
                child: Text('Charts Page'),
              ),
            )
          ],
        ),
        // Add your chart widgets here
      ),
    );
  }
}
