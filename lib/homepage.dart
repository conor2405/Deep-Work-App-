import 'package:deep_work/widgets/central_timer.dart';
import 'package:deep_work/widgets/todo_list.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Row(
        children: [
          // left column
          Expanded(
            child: Column(
              children: <Widget>[
                // top left
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.blueGrey),
                    child: TodoList(),
                  ),
                ),
                // center left
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.blueGrey),
                    child: Center(child: Text('Center Left')),
                  ),
                ),
                // bottom left
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      color: Colors.blueGrey,
                    ),
                    child: Center(child: Text('Bottom Left')),
                  ),
                ),
              ],
            ),
          ),
          // central column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // top center
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.blueGrey),
                    child: Center(child: Text('Top Center')),
                  ),
                ),
                // center center
                Expanded(
                  child: Container(
                    child: CentralTimer(),
                  ),
                ),
                // bottom center
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.blueGrey),
                    child: Center(child: Text('Bottom Center')),
                  ),
                ),
              ],
            ),
          ),
          // right column
          Expanded(
            child: Column(
              children: <Widget>[
                // top right
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.blueGrey),
                    child: Center(child: Text('Top Right')),
                  ),
                ),
                // center right
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.blueGrey),
                    child: Center(child: Text('Center Right')),
                  ),
                ),
                // bottom right
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.blueGrey),
                    child: Center(child: Text('Bottom Right')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
  
      // This trailing comma makes auto-formatting nicer for build methods.
 