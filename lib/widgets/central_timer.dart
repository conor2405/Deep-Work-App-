import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/time.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class CentralTimer extends StatefulWidget {
  CentralTimer({super.key});
  int time = 90; // default time is 90 minutes

  @override
  State<CentralTimer> createState() => _CentralTimerState();
}

class _CentralTimerState extends State<CentralTimer> {
  static const Key _homeDateKey = Key('home-date');
  static const Key _homeTimeKey = Key('home-time');

  Widget _buildHomeDateTime(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final alwaysUse24Hour = MediaQuery.of(context).alwaysUse24HourFormat;
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<DateTime>(
      stream: Stream<DateTime>.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final dateText = localizations.formatMediumDate(now).toUpperCase();
        final timeText = localizations.formatTimeOfDay(
          TimeOfDay.fromDateTime(now),
          alwaysUse24HourFormat: alwaysUse24Hour,
        );
        final dateStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 13,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w500,
              color: colorScheme.onBackground.withOpacity(0.6),
            );
        final timeStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w200,
              letterSpacing: 0.6,
              color: colorScheme.onBackground.withOpacity(0.9),
            );
        final chromeColor = colorScheme.onBackground.withOpacity(0.08);
        final surfaceColor = colorScheme.surface.withOpacity(0.12);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: chromeColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(dateText, key: _homeDateKey, style: dateStyle),
              const SizedBox(height: 2),
              Text(timeText, key: _homeTimeKey, style: timeStyle),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showBreakDialog(BuildContext context) async {
    int selectedMinutes = 5;
    final int? breakMinutes = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Take a break'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: selectedMinutes <= 5
                        ? null
                        : () => setState(() => selectedMinutes -= 5),
                  ),
                  Text(
                    '$selectedMinutes min',
                    style: TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => setState(() => selectedMinutes += 5),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedMinutes),
                  child: Text('Start Break'),
                ),
              ],
            );
          },
        );
      },
    );

    if (breakMinutes != null && breakMinutes > 0) {
      BlocProvider.of<TimerBloc>(context).add(
        TimerStartBreak(TimeModel(breakMinutes * 60)),
      );
    }
  }

  Future<void> _showEndSessionDialog(BuildContext context) async {
    final bool? shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('End session?'),
          content: Text('Are you sure you want to end this focus session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('End Session'),
            ),
          ],
        );
      },
    );

    if (shouldEnd == true) {
      BlocProvider.of<TimerBloc>(context).add(TimerEnd());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        if (state is TimerInitial) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHomeDateTime(context),
              const SizedBox(height: 16),
              Stack(alignment: Alignment.center, children: [
                ConstrainedBox(
                  constraints: BoxConstraints.tight(Size(500, 500)),
                  child: SleekCircularSlider(
                    appearance: CircularSliderAppearance(
                      infoProperties: InfoProperties(
                        mainLabelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                        topLabelText: 'Time Remaining',
                      ),
                      customWidths: CustomSliderWidths(
                          progressBarWidth: 3,
                          trackWidth: 3,
                          shadowWidth: 1,
                          handlerSize: 7),
                      customColors: CustomSliderColors(
                        progressBarColors: [
                          Theme.of(context).colorScheme.primary,
                          Colors.blue.shade100
                        ],
                        trackColor: Colors.grey,
                        shadowColor: Colors.black,
                        shadowMaxOpacity: 0.05,
                        shadowStep: 10,
                        dotColor: Theme.of(context).colorScheme.onBackground,
                        hideShadow: false,
                        gradientStartAngle: 0,
                        gradientEndAngle: 180,
                      ),
                      animDurationMultiplier: 0.5,
                    ),
                    min: 0,
                    max: 180,
                    initialValue: state.time.getTrimmedTimeMinutes.toDouble(),
                    onChange: (double value) {
                      // callback providing a value while its being changed (with a pan gesture)
                      final TimeModel time = TimeModel(value.toInt() * 60);
                      BlocProvider.of<TimerBloc>(context).add(TimeUpdate(time));
                    },
                    onChangeStart: (double startValue) {
                      // callback providing a starting value (when a pan gesture starts)
                      final TimeModel time = TimeModel(startValue.toInt() * 60);
                      BlocProvider.of<TimerBloc>(context).add(TimeUpdate(time));
                    },
                    onChangeEnd: (double endValue) {
                      // ucallback providing an ending value (when a pan gesture ends)
                      final TimeModel time = TimeModel(endValue.toInt() * 60);
                      BlocProvider.of<TimerBloc>(context).add(TimeUpdate(time));
                    },
                    innerWidget: (double percentage) {
                      int _percentage_int = percentage.toInt();
                      int hours = (_percentage_int / 60).floor();
                      int minutes = (_percentage_int % 60);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              state.time.timeString,
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w200),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  BlocProvider.of<TimerBloc>(context)
                                      .add(TimerStart());
                                },
                                icon: Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ]),
            ],
          );
        } else if (state is TimerBreakRunning) {
          final maxSeconds = state.timeModel.breakTargetTime.seconds > 0
              ? state.timeModel.breakTargetTime.seconds.toDouble()
              : state.timeModel.breakTimeLeft.seconds.toDouble();
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(Size(500, 500)),
              child: SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  infoProperties: InfoProperties(
                    mainLabelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                    topLabelText: 'Break Remaining',
                  ),
                  customWidths: CustomSliderWidths(
                      progressBarWidth: 3,
                      trackWidth: 3,
                      shadowWidth: 1,
                      handlerSize: 7),
                  customColors: CustomSliderColors(
                    progressBarColors: [
                      Theme.of(context).colorScheme.tertiary,
                      Colors.orange.shade100
                    ],
                    trackColor: Colors.grey,
                    shadowColor: Colors.black,
                    shadowMaxOpacity: 0.05,
                    shadowStep: 10,
                    dotColor: Colors.black,
                    hideShadow: false,
                    gradientStartAngle: 0,
                    gradientEndAngle: 180,
                  ),
                  animDurationMultiplier: 0.5,
                ),
                min: 0,
                max: maxSeconds == 0 ? 1 : maxSeconds,
                initialValue:
                    state.timeModel.breakTimeLeft.seconds.toDouble(),
                innerWidget: (double percentage) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.timeModel.breakTimeLeft.timeString,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w200)),
                        TextButton(
                          onPressed: () {
                            BlocProvider.of<TimerBloc>(context)
                                .add(TimerEndBreak());
                          },
                          child: Text('End Break'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(50.0),
                              child: IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () =>
                                    BlocProvider.of<TimerBloc>(context)
                                        .add(TimerBreakTakeFive()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(50),
                              child: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () =>
                                    BlocProvider.of<TimerBloc>(context)
                                        .add(TimerBreakAddFive()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        } else if (state is TimerRunning && state is! TimerDone) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(Size(500, 500)),
              child: SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  infoProperties: InfoProperties(
                    mainLabelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                    topLabelText: 'Time Remaining',
                  ),
                  customWidths: CustomSliderWidths(
                      progressBarWidth: 3,
                      trackWidth: 3,
                      shadowWidth: 1,
                      handlerSize: 7),
                  customColors: CustomSliderColors(
                    progressBarColors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary
                    ],
                    trackColor: Colors.grey,
                    shadowColor: Colors.black,
                    shadowMaxOpacity: 0.05,
                    shadowStep: 10,
                    dotColor: Colors.black,
                    hideShadow: false,
                    gradientStartAngle: 0,
                    gradientEndAngle: 180,
                  ),
                  animDurationMultiplier: 0.5,
                ),
                min: 0,
                max: state.timeModel.targetTime.seconds.toDouble(),
                initialValue: state.timeModel.timeLeft.seconds.toDouble(),
                innerWidget: (double percentage) {
                  int _percentage_int = percentage.toInt();
                  int hours = (_percentage_int / 60).floor();
                  int minutes = (_percentage_int % 60);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.timeModel.timeLeft.timeString,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w200)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(50.0),
                              child: IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () =>
                                    BlocProvider.of<TimerBloc>(context)
                                        .add(TimerTakeFive()),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(50),
                              child: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () =>
                                    BlocProvider.of<TimerBloc>(context)
                                        .add(TimerAddFive()),
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          icon: Icon(Icons.stop_circle_outlined),
                          onPressed: () => _showEndSessionDialog(context),
                          label: Text('End Session'),
                        ),
                        OutlinedButton.icon(
                          icon: Icon(Icons.free_breakfast),
                          onPressed: () => _showBreakDialog(context),
                          label: Text('Take Break'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        } else if (state is TimerDone) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(Size(500, 500)),
              child: SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  infoProperties: InfoProperties(
                    mainLabelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                    topLabelText: 'Time Remaining',
                  ),
                  customWidths: CustomSliderWidths(
                      progressBarWidth: 3,
                      trackWidth: 3,
                      shadowWidth: 1,
                      handlerSize: 7),
                  customColors: CustomSliderColors(
                    progressBarColors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary
                    ],
                    trackColor: Colors.grey,
                    shadowColor: Colors.black,
                    shadowMaxOpacity: 0.05,
                    shadowStep: 10,
                    dotColor: Colors.black,
                    hideShadow: false,
                    gradientStartAngle: 0,
                    gradientEndAngle: 180,
                  ),
                  animDurationMultiplier: 0.5,
                ),
                min: 0,
                max: state.timeModel.targetTime.seconds.toDouble(),
                initialValue: state.timeModel.timeLeft.seconds.toDouble(),
                innerWidget: (double percentage) {
                  int _percentage_int = percentage.toInt();
                  int hours = (_percentage_int / 60).floor();
                  int minutes = (_percentage_int % 60);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.timeModel.timeLeft.timeString,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w200)),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return Center(child: Text('error loading timer'));
        }
      },
    );
  }
}
