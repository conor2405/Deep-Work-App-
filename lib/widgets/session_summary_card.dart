import 'dart:math' as math;

import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:flutter/material.dart';

class SessionSummaryCard extends StatelessWidget {
  final _SessionSummaryData data;
  final VoidCallback? onTap;

  const SessionSummaryCard._(this.data, {this.onTap, super.key});

  factory SessionSummaryCard.fromTimerStats({
    required TimerStats timeModel,
    VoidCallback? onTap,
    Key? key,
  }) {
    return SessionSummaryCard._(
      _SessionSummaryData.fromTimerStats(timeModel),
      onTap: onTap,
      key: key,
    );
  }

  factory SessionSummaryCard.fromTimerResult({
    required TimerResult timeResult,
    VoidCallback? onTap,
    Key? key,
  }) {
    return SessionSummaryCard._(
      _SessionSummaryData.fromTimerResult(timeResult),
      onTap: onTap,
      key: key,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final focusTime = TimeModel(data.timeRun).timeString;
    final breakTime = TimeModel(data.breakTime).timeString;
    final startedAt = TimeOfDay.fromDateTime(data.startTime).format(context);
    final sessionSeconds = math.max(1, data.timeRun + data.breakTime);
    final breakSegments =
        _buildBreakSegments(data, sessionSeconds.toDouble());

    final content = Padding(
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
    );

    return Card(
      elevation: 0,
      color: colorScheme.surface.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: content,
            ),
    );
  }

  List<_TimelineSegment> _buildBreakSegments(
    _SessionSummaryData data,
    double sessionSeconds,
  ) {
    final sessionStart = data.startTime;
    final sessionEnd =
        data.startTime.add(Duration(seconds: sessionSeconds.round()));
    return data.breakEvents.map((event) {
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

class _SessionSummaryData {
  final int timeRun;
  final int breakTime;
  final DateTime startTime;
  final List<BreakPeriod> breakEvents;

  const _SessionSummaryData({
    required this.timeRun,
    required this.breakTime,
    required this.startTime,
    required this.breakEvents,
  });

  factory _SessionSummaryData.fromTimerStats(TimerStats stats) {
    return _SessionSummaryData(
      timeRun: stats.timeRun,
      breakTime: stats.breakTime,
      startTime: stats.startTime,
      breakEvents: stats.breakEvents,
    );
  }

  factory _SessionSummaryData.fromTimerResult(TimerResult result) {
    return _SessionSummaryData(
      timeRun: result.timeRun,
      breakTime: result.breakTime,
      startTime: result.startTime,
      breakEvents: result.breakEvents,
    );
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
