import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/widgets/day_bar.dart';
import 'package:deep_work/widgets/day_selector.dart';
import 'package:deep_work/widgets/graphic_weekly_chart.dart';
import 'package:deep_work/widgets/session_detail_page.dart';
import 'package:deep_work/widgets/session_summary_card.dart';
import 'package:deep_work/widgets/sidebar.dart';
import 'package:deep_work/widgets/timegoals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final scrollContent = CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 20, 8),
                  sliver: SliverToBoxAdapter(child: DaySelector()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
                      builder: (context, state) {
                        if (state is LeaderboardLoaded) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              state.dailySessions.totalMinutes.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w200),
                            ),
                          );
                        }
                        return const SizedBox(height: 1);
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: DayBar(changeableDate: true),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: GraphicWeeklyChart(changeableDate: true),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 16,
                      runSpacing: 16,
                      children: const [
                        SizedBox(
                          width: 110,
                          child: TimeGoalsWidget(
                            goalType: 'daily',
                            changeableDate: true,
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: TimeGoalsWidget(goalType: 'weekly'),
                        ),
                        SizedBox(
                          width: 110,
                          child: TimeGoalsWidget(goalType: 'monthly'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverToBoxAdapter(child: _SessionSummaryList()),
                ),
              ],
            );

            if (isWide) {
              return Row(
                children: [
                  Sidebar(),
                  Expanded(child: scrollContent),
                ],
              );
            }

            return scrollContent;
          },
        ),
      ),
    );
  }
}

class _SessionSummaryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is! LeaderboardLoaded) {
          return const SizedBox.shrink();
        }

        final sessions = state.dailySessions.sessions;
        if (sessions.isEmpty) {
          return Text(
            'No sessions for this day yet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Session summaries',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            for (final session in sessions) ...[
              SessionSummaryCard.fromTimerResult(
                timeResult: session,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SessionDetailPage(session: session),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}
