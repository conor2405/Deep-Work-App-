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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () {
                      BlocProvider.of<LeaderboardBloc>(context)
                          .add(BackArrowPressed());
                    },
                    child: Container(
                      width: 25,
                      height: 60,
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
                            size: 20),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: dayList(state, context),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () {
                      BlocProvider.of<LeaderboardBloc>(context)
                          .add(ForwardArrowPressed());
                    },
                    child: Container(
                      width: 25,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20),
                      ),
                    ),
                  ),
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
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<LeaderboardBloc>(context)
              .add(SelectDate(state.dates[i]));
        },
        child: Container(
          width: 60,
          height: 60,
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
