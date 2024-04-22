import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/widgets/central_timer.dart';
import 'package:deep_work/widgets/day_bar.dart';
import 'package:deep_work/widgets/example_barchart.dart';
import 'package:deep_work/widgets/graphic_weekly_chart.dart';
import 'package:deep_work/widgets/monthly_scoreboard.dart';
import 'package:deep_work/widgets/sidebar.dart';
import 'package:deep_work/widgets/timegoals.dart';
import 'package:deep_work/widgets/todo_list.dart';
import 'package:deep_work/widgets/weekly_scoreboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Sidebar(),
            Container(
              width: 200,
              child: TimeGoalsWidget(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 30, 5, 5),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        child: CentralTimer(),
                        height: 500,
                      ),
                    ),
                    DayBar(),
                    Container(
                      child: GraphicWeeklyChart(),
                      height: 300,
                    ),

                    Container(child: TodoList(), height: 300),

                    // center left
                    // Expanded(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.black, width: 2),
                    //       color: Colors.blueGrey,
                    //     ),
                    //     child: Center(child: Text('Center Left')),
                    //   ),
                    // ),
                    // bottom left

                    // // top center
                    // Expanded(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.black, width: 2),
                    //       color: Colors.blueGrey,
                    //     ),
                    //     child: Center(child: Text('Top Center')),
                    //   ),
                    // ),
                    // // center center

                    // // bottom center
                    // Expanded(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.black, width: 2),
                    //       color: Colors.blueGrey,
                    //     ),
                    //     child: WeeklyScoreboard(),
                    //   ),
                    // ),
                    // // top right
                    // Expanded(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.black, width: 2),
                    //       color: Colors.blueGrey,
                    //     ),
                    //     child: Center(child: Text('Top Right')),
                    //   ),
                    // ),
                    // // center right
                    // Expanded(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.black, width: 2),
                    //       color: Colors.blueGrey,
                    //     ),
                    //     child: Center(child: Text('centre Right')),
                    //   ),
                    // ),
                    // // bottom right
                    // Expanded(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.black, width: 2),
                    //       color: Colors.blueGrey,
                    //     ),
                    //     child: MonthlyScoreboardWidget(),
                    //  ),
                    //),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This trailing comma makes auto-formatting nicer for build methods.
