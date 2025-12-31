import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/widgets/central_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimerDonePage extends StatefulWidget {
  @override
  _TimerDonePageState createState() => _TimerDonePageState();
}

class _TimerDonePageState extends State<TimerDonePage> {
  final TextEditingController _notesController = TextEditingController();
  int? _focusRating;
  static const List<_FocusRatingOption> _focusOptions = [
    _FocusRatingOption(1, 'Very distracted', '😵‍💫'),
    _FocusRatingOption(2, 'Mostly distracted', '😕'),
    _FocusRatingOption(3, 'Mixed / okay', '😐'),
    _FocusRatingOption(4, 'Mostly focused', '🙂'),
    _FocusRatingOption(5, 'Deep focus', '🎯'),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitNotes(BuildContext context) {
    final note = _notesController.text.trim();
    if (note.isEmpty) {
      return;
    }

    BlocProvider.of<TimerBloc>(context).add(TimerSetNotes(note));
    BlocProvider.of<TimerBloc>(context).add(TimerSubmitNotes());
  }

  void _submitFocusRating(BuildContext context) {
    if (_focusRating == null) {
      return;
    }
    BlocProvider.of<TimerBloc>(context)
        .add(TimerSetFocusRating(_focusRating));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimerBloc, TimerState>(
      listener: (context, state) {
        if (state is TimerInitial) {
          Navigator.popUntil(context, ModalRoute.withName('/'));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Timer Done Page'),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            final showNotes =
                settingsState is SettingsInitial && settingsState.showNotes;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 400,
                        width: 400,
                        child: CentralTimer(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'How focused did you feel?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: _focusOptions.map((option) {
                          return RadioListTile<int>(
                            value: option.value,
                            groupValue: _focusRating,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _focusRating = value;
                              });
                            },
                            title: Text(
                              '${option.value}. ${option.label} ${option.emoji}',
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                      if (showNotes) ...[
                        const SizedBox(height: 24),
                        Text(
                          'What did you get done?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          keyboardType: TextInputType.multiline,
                          minLines: 3,
                          maxLines: 6,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText:
                                'Capture a quick reflection before you move on.',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          _submitFocusRating(context);
                          _submitNotes(context);
                          BlocProvider.of<TimerBloc>(context).add(TimerConfirm());
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          BlocProvider.of<LeaderboardBloc>(context)
                              .add(LeaderboardRefresh());
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FocusRatingOption {
  final int value;
  final String label;
  final String emoji;

  const _FocusRatingOption(this.value, this.label, this.emoji);
}
