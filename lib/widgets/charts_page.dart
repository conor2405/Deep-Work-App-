import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/widgets/day_bar.dart';
import 'package:deep_work/widgets/day_selector.dart';
import 'package:deep_work/widgets/graphic_weekly_chart.dart';
import 'package:deep_work/widgets/notes_list.dart';
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
                  sliver: SliverToBoxAdapter(child: WidgetForNotesList()),
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
