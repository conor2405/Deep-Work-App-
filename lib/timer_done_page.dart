import 'dart:math' as math;

import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
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
            return BlocBuilder<TimerBloc, TimerState>(
              builder: (context, timerState) {
                final timerStats = timerState is TimerRunning
                    ? timerState.timeModel
                    : null;
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
                          const _CompletionHeader(),
                          const SizedBox(height: 24),
                          if (timerStats != null) ...[
                            _SessionSummaryCard(timeModel: timerStats),
                            const SizedBox(height: 24),
                          ],
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
                              BlocProvider.of<TimerBloc>(context)
                                  .add(TimerConfirm());
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

class _CompletionHeader extends StatelessWidget {
  const _CompletionHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withOpacity(0.15),
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: accent,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Nice work finishing your session!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Take a breath and capture how it went.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  final TimerStats timeModel;

  const _SessionSummaryCard({required this.timeModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final focusTime = TimeModel(timeModel.timeRun).timeString;
    final breakTime = TimeModel(timeModel.breakTime).timeString;
    final startedAt = TimeOfDay.fromDateTime(timeModel.startTime).format(context);
    final sessionSeconds = math.max(1, timeModel.timeRun + timeModel.breakTime);
    final breakSegments =
        _buildBreakSegments(timeModel, sessionSeconds.toDouble());

    return Card(
      elevation: 0,
      color: colorScheme.surface.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session timeline',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _SessionTimeline(
              breakSegments: breakSegments,
              focusColor: colorScheme.primary.withOpacity(0.4),
              breakColor: colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _LegendItem(
                  color: colorScheme.primary.withOpacity(0.5),
                  label: 'Focused',
                ),
                _LegendItem(
                  color: colorScheme.secondary,
                  label: 'Breaks',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _SummaryStat(label: 'Focus time', value: focusTime),
                _SummaryStat(label: 'Break time', value: breakTime),
                _SummaryStat(label: 'Started at', value: startedAt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<_TimelineSegment> _buildBreakSegments(
    TimerStats timeModel,
    double sessionSeconds,
  ) {
    final sessionStart = timeModel.startTime;
    final sessionEnd =
        timeModel.startTime.add(Duration(seconds: sessionSeconds.round()));
    return timeModel.breakEvents.map((event) {
      final start = event.startTime;
      final end = event.endTime ?? sessionEnd;
      final startOffset = start.difference(sessionStart).inSeconds.toDouble();
      final endOffset = end.difference(sessionStart).inSeconds.toDouble();
      final clampedStart = startOffset.clamp(0, sessionSeconds);
      final clampedEnd = endOffset.clamp(0, sessionSeconds);
      return _TimelineSegment(
        startFraction: clampedStart / sessionSeconds,
        endFraction: clampedEnd / sessionSeconds,
      );
    }).where((segment) => segment.endFraction > segment.startFraction).toList();
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTimeline extends StatelessWidget {
  final List<_TimelineSegment> breakSegments;
  final Color focusColor;
  final Color breakColor;

  const _SessionTimeline({
    required this.breakSegments,
    required this.focusColor,
    required this.breakColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('sessionTimelineBar'),
      height: 36,
      width: double.infinity,
      child: CustomPaint(
        painter: _SessionTimelinePainter(
          breakSegments: breakSegments,
          focusColor: focusColor,
          breakColor: breakColor,
        ),
      ),
    );
  }
}

class _SessionTimelinePainter extends CustomPainter {
  final List<_TimelineSegment> breakSegments;
  final Color focusColor;
  final Color breakColor;

  _SessionTimelinePainter({
    required this.breakSegments,
    required this.focusColor,
    required this.breakColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final focusPaint = Paint()
      ..color = focusColor
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final breakPaint = Paint()
      ..color = breakColor
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      focusPaint,
    );

    for (final segment in breakSegments) {
      final startX = segment.startFraction * size.width;
      final endX = segment.endFraction * size.width;
      canvas.drawLine(
        Offset(startX, centerY),
        Offset(endX, centerY),
        breakPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SessionTimelinePainter oldDelegate) {
    return oldDelegate.breakSegments != breakSegments ||
        oldDelegate.focusColor != focusColor ||
        oldDelegate.breakColor != breakColor;
  }
}

class _TimelineSegment {
  final double startFraction;
  final double endFraction;

  _TimelineSegment({
    required this.startFraction,
    required this.endFraction,
  });
}
