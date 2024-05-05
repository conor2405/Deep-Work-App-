import 'package:deep_work/widgets/day_bar.dart';
import 'package:deep_work/widgets/day_selector.dart';
import 'package:deep_work/widgets/graphic_weekly_chart.dart';
import 'package:deep_work/widgets/sidebar.dart';
import 'package:deep_work/widgets/timegoals.dart';
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
        child: Row(children: [
          Sidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 30, 5, 5),
              child: ListView(children: [
                DaySelector(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
                  child: DayBar(),
                ),
                Container(
                  child: GraphicWeeklyChart(),
                  height: 300,
                ),
                SizedBox(
                  height: 100,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 100,
                        child: TimeGoalsWidget(
                          goalType: 'daily',
                        ),
                      ),
                      Container(
                        width: 100,
                        child: TimeGoalsWidget(
                          goalType: 'weekly',
                        ),
                      ),
                      Container(
                        width: 100,
                        child: TimeGoalsWidget(
                          goalType: 'monthly',
                        ),
                      ),
                    ]),
              ]),
            ),
          ),
        ]),
        // Add your chart widgets here
      ),
    );
  }
}
