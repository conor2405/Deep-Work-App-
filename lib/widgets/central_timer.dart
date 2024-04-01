import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class CentralTimer extends StatefulWidget {
  const CentralTimer({super.key});

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
                            )),
                        min: 0,
                        max: 360,
                        initialValue: 45,
                        onChange: (double value) {
                          // callback providing a value while its being changed (with a pan gesture)
                        },
                        onChangeStart: (double startValue) {
                          // callback providing a starting value (when a pan gesture starts)
                        },
                        onChangeEnd: (double endValue) {
                          // ucallback providing an ending value (when a pan gesture ends)
                        },
                        innerWidget: (double percentage) {
                          int _percentage_int = percentage.toInt();
                          int hours = (_percentage_int / 60).floor();
                          int minutes = (_percentage_int % 60);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  hours.toString() +
                                      ":" +
                                      (minutes < 10
                                          ? '0' + minutes.toString()
                                          : minutes.toString()),
                                  style: TextStyle(
                                      fontSize: 50, color: Colors.black)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.replay)),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.pause)),
                                  IconButton(
                                    onPressed: () {},
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
          },
        ),
      ),
    );
  }
}
