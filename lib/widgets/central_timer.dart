import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/repo/firestore_repo.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class CentralTimer extends StatefulWidget {
  CentralTimer({super.key});
  int time = 90; // default time is 90 minutes

  @override
  State<CentralTimer> createState() => _CentralTimerState();
}

class _CentralTimerState extends State<CentralTimer> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        if (state is TimerInitial) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
        } else if (state is TimerRunning && state is! TimerDone) {
          return SleekCircularSlider(
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
                        state is TimerPaused
                            ? IconButton(
                                onPressed: () {
                                  BlocProvider.of<TimerBloc>(context)
                                      .add(TimerStop());
                                },
                                icon: Icon(
                                  Icons.stop,
                                  size: 50,
                                ))
                            : Container(),
                        IconButton(
                            onPressed: () {
                              BlocProvider.of<TimerBloc>(context)
                                  .add(TimerPause());
                            },
                            icon: Icon(
                              Icons.pause,
                              size: 50,
                            )),
                        IconButton(
                          onPressed: () {
                            BlocProvider.of<TimerBloc>(context)
                                .add(TimerResume());
                          },
                          icon: Icon(
                            Icons.play_arrow,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => BlocProvider.of<TimerBloc>(context)
                                .add(TimerTakeFive()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(50),
                          child: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => BlocProvider.of<TimerBloc>(context)
                                .add(TimerAddFive()),
                          ),
                        ),
                      ],
                    ),
                    (BlocProvider.of<SettingsBloc>(context).state
                                as SettingsInitial)
                            .showNotes
                        ? IconButton(
                            icon: Icon(Icons.notes_rounded),
                            onPressed: () {
                              BlocProvider.of<SettingsBloc>(context).add(
                                ToggleNotes(),
                              );
                            })
                        : Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: Stack(children: [
                              TextField(
                                keyboardType: TextInputType.multiline,
                                onChanged: (value) {
                                  BlocProvider.of<TimerBloc>(context).add(
                                    TimerSetNotes(value),
                                  );
                                },
                                maxLines: null,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText:
                                      '''Action may not always bring happiness,
but there is no happiness without action.''',
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () {
                                    BlocProvider.of<SettingsBloc>(context).add(
                                      ToggleNotes(),
                                    );

                                    BlocProvider.of<TimerBloc>(context).add(
                                      TimerSubmitNotes(),
                                    );
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              )
                            ]),
                          ),
                  ],
                ),
              );
            },
          );
        }
        // } else if (state is TimerDone) {
        //   return SleekCircularSlider(
        //     appearance: CircularSliderAppearance(
        //       infoProperties: InfoProperties(
        //         mainLabelStyle: TextStyle(
        //             color: Colors.black,
        //             fontSize: 24,
        //             fontWeight: FontWeight.w700),
        //         topLabelText: 'Time Remaining',
        //       ),
        //       customWidths: CustomSliderWidths(
        //           progressBarWidth: 3,
        //           trackWidth: 3,
        //           shadowWidth: 1,
        //           handlerSize: 7),
        //       customColors: CustomSliderColors(
        //         progressBarColors: [
        //           Theme.of(context).colorScheme.primary,
        //           Theme.of(context).colorScheme.tertiary
        //         ],
        //         trackColor: Colors.grey,
        //         shadowColor: Colors.black,
        //         shadowMaxOpacity: 0.05,
        //         shadowStep: 10,
        //         dotColor: Colors.black,
        //         hideShadow: false,
        //         gradientStartAngle: 0,
        //         gradientEndAngle: 180,
        //       ),
        //       animDurationMultiplier: 0.5,
        //     ),
        //     min: 0,
        //     max: state.timeModel.targetTime.seconds.toDouble(),
        //     initialValue: state.timeModel.timeLeft.seconds.toDouble(),
        //     innerWidget: (double percentage) {
        //       int _percentage_int = percentage.toInt();
        //       int hours = (_percentage_int / 60).floor();
        //       int minutes = (_percentage_int % 60);
        //       return Center(
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Text(state.timeModel.timeLeft.timeString,
        //                 style: TextStyle(
        //                     fontSize: 30, fontWeight: FontWeight.w200)),
        //           ],
        //         ),
        //       );
        //     },
        //   );
        // }
        else {
          return Center(child: Text('error loading timer'));
        }
      },
    );
  }
}
