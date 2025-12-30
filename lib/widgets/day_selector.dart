import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DaySelector extends StatefulWidget {
  @override
  _DaySelectorState createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          return Container(
            child: Column(
              children: [
                state.selectedDate
                            .copyWith(
                                hour: 0, minute: 0, second: 0, microsecond: 0)
                            .difference(DateTime.now().copyWith(
                                hour: 0, minute: 0, second: 0, microsecond: 0))
                            .inHours
                            .abs() <
                        23
                    ? Text('Today')
                    : Text(
                        '${state.selectedDate.day}/${state.selectedDate.month}/${state.selectedDate.year}'),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () {
                          BlocProvider.of<LeaderboardBloc>(context)
                              .add(BackArrowPressed());
                        },
                        child: Container(
                          width: 32,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                            child: Icon(Icons.arrow_back_ios,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18),
                          ),
                        ),
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: dayList(state, context),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () {
                          BlocProvider.of<LeaderboardBloc>(context)
                              .add(ForwardArrowPressed());
                        },
                        child: Container(
                          width: 32,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: Center(
                            child: Icon(Icons.arrow_forward_ios,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                !isSameDay(state.selectedDate, DateTime.now())
                    ? ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<LeaderboardBloc>(context)
                              .add(SelectDate(DateTime.now()));
                        },
                        child: Text('Today'))
                    : Container(
                        height: 31,
                      ),
              ],
            ),
          );
        } else {
          return Container(
            child: Text('Error loading day selector'),
          );
        }
      },
    );
  }
}

List<Widget> dayList(LeaderboardLoaded state, BuildContext context) {
  List<Widget> days = [];

  for (int i = 0; i < 7; i++) {
    // getting the day string from i
    String day;
    switch (i) {
      case 0:
        day = 'Mon';
        break;
      case 1:
        day = 'Tue';
        break;
      case 2:
        day = 'Wed';
        break;
      case 3:
        day = 'Thu';
        break;
      case 4:
        day = 'Fri';
        break;
      case 5:
        day = 'Sat';
        break;
      case 6:
        day = 'Sun';
        break;
      default:
        day = 'Error';
    }

    days.add(Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () {
          BlocProvider.of<LeaderboardBloc>(context)
              .add(SelectDate(state.dates[i]));
        },
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: state.selectedDate.day == state.dates[i].day
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(day, textAlign: TextAlign.center),
                Text(state.dates[i].day.toString(), textAlign: TextAlign.center)
              ],
            ),
          ),
        ),
      ),
    ));
  }
  return days;
}

bool isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
