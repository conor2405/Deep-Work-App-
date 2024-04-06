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
    return RepositoryProvider(
      create: (context) => FirestoreRepo(),
      child: BlocProvider(
        create: (context) =>
            TimerBloc(RepositoryProvider.of<FirestoreRepo>(context)),
        child: BlocBuilder<TimerBloc, TimerState>(
          builder: (context, state) {
            if (state is TimerInitial) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Stack(alignment: Alignment.center, children: [
                      ConstrainedBox(
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
                              progressBarColors: [Colors.blue, Colors.red],
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
                          max: 180,
                          initialValue:
                              state.time.getTrimmedTimeMinutes.toDouble(),

                          //value: state.time.getTrimmedTimeMinutes,
                          onChange: (double value) {
                            // callback providing a value while its being changed (with a pan gesture)
                            final TimeModel time =
                                TimeModel(value.toInt() * 60);
                            BlocProvider.of<TimerBloc>(context)
                                .add(TimeUpdate(time));
                          },
                          onChangeStart: (double startValue) {
                            // callback providing a starting value (when a pan gesture starts)
                            final TimeModel time =
                                TimeModel(startValue.toInt() * 60);
                            BlocProvider.of<TimerBloc>(context)
                                .add(TimeUpdate(time));
                          },
                          onChangeEnd: (double endValue) {
                            // ucallback providing an ending value (when a pan gesture ends)
                            final TimeModel time =
                                TimeModel(endValue.toInt() * 60);
                            BlocProvider.of<TimerBloc>(context)
                                .add(TimeUpdate(time));
                          },
                          innerWidget: (double percentage) {
                            int _percentage_int = percentage.toInt();
                            int hours = (_percentage_int / 60).floor();
                            int minutes = (_percentage_int % 60);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: EditableText(
                                    cursorColor: Colors.black,
                                    controller: TextEditingController(
                                        text: state.time.minutes.toString()),
                                    focusNode: FocusNode(),
                                    backgroundCursorColor: Colors.black,
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.black),
                                    textAlign: TextAlign.center,
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        value = '0';
                                      }
                                      TimeModel time =
                                          TimeModel(int.parse(value) * 60);
                                      BlocProvider.of<TimerBloc>(context)
                                          .add(TimeUpdate(time));
                                    },
                                    onSubmitted: (value) {
                                      if (value.isEmpty) {
                                        value = '0';
                                      }
                                      print('submitted');
                                      TimeModel time =
                                          TimeModel(int.parse(value) * 60);
                                      BlocProvider.of<TimerBloc>(context)
                                          .add(TimeUpdate(time));
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3)
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          BlocProvider.of<TimerBloc>(context)
                                              .add(TimerReset());
                                        },
                                        icon: Icon(Icons.replay)),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.pause)),
                                    IconButton(
                                      onPressed: () {
                                        BlocProvider.of<TimerBloc>(context)
                                            .add(TimerStart());
                                      },
                                      icon: Icon(Icons.play_arrow),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                ],
              );
            } else if (state is TimerRunning) {
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
                    progressBarColors: [Colors.blue, Colors.red],
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
                max: state.timeModel.seconds.toDouble(),
                initialValue: state.timeModel.seconds.toDouble(),
              );

              Text(state.timeModel.timeString);
            } else {
              return Center(child: Text('error loading timer'));
            }
          },
        ),
      ),
    );
  }
}
