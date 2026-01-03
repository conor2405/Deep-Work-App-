import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/widgets/session_summary_card.dart';
import 'package:flutter/material.dart';

class SessionDetailPage extends StatelessWidget {
  const SessionDetailPage({
    super.key,
    required this.session,
  });

  final TimerResult session;

  static const List<_FocusRatingOption> _focusOptions = [
    _FocusRatingOption(1, 'Very distracted', '😵‍💫'),
    _FocusRatingOption(2, 'Mostly distracted', '😕'),
    _FocusRatingOption(3, 'Mixed / okay', '😐'),
    _FocusRatingOption(4, 'Mostly focused', '🙂'),
    _FocusRatingOption(5, 'Deep focus', '🎯'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final startDate =
        localizations.formatFullDate(session.startTime).toString();
    final startTime =
        localizations.formatTimeOfDay(TimeOfDay.fromDateTime(session.startTime));
    final endDate =
        localizations.formatFullDate(session.timeFinished).toString();
    final endTime = localizations
        .formatTimeOfDay(TimeOfDay.fromDateTime(session.timeFinished));
    final focusSummary = _focusOptions
        .firstWhere(
          (option) => option.value == session.focusRating,
          orElse: () => const _FocusRatingOption(0, 'Not rated yet', ''),
        )
        .labelWithEmoji;
    final notes = session.notes
        .map((note) => note.trim())
        .where((note) => note.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session details'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SessionSummaryCard.fromTimerResult(timeResult: session),
                const SizedBox(height: 24),
                Text(
                  'Session info',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  children: [
                    _DetailRow(
                      label: 'Started',
                      value: '$startDate · $startTime',
                    ),
                    _DetailRow(
                      label: 'Finished',
                      value: '$endDate · $endTime',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Focus rating',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  children: [
                    _DetailRow(
                      label: 'How you felt',
                      value: focusSummary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Reflection notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailCard(
                  children: notes.isEmpty
                      ? [
                          Text(
                            'No notes for this session.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ]
                      : notes
                          .map(
                            (note) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '• $note',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusRatingOption {
  final int value;
  final String label;
  final String emoji;

  const _FocusRatingOption(this.value, this.label, this.emoji);

  String get labelWithEmoji => emoji.isEmpty ? label : '$label $emoji';
}
