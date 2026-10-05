import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/habits/presentation/cubit/habits_cubit.dart';
import '../features/habits/presentation/cubit/habits_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/five_day_view.dart';
import '../widgets/habit_editor_sheet.dart';
import '../widgets/month_cards_view.dart';
import '../widgets/view_switcher.dart';
import '../widgets/year_heatmap_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _view = 0;

  Future<void> _showCreate() => openHabitEditor(context);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            BlocBuilder<HabitsCubit, HabitsState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return IndexedStack(
                  index: _view,
                  children: const [
                    YearHeatmapView(),
                    FiveDayView(),
                    MonthCardsView(),
                  ],
                );
              },
            ),
            Positioned(
              top: 8,
              right: 12,
              child: Material(
                elevation: 16,
                shadowColor: Colors.black.withValues(alpha: 0.35),
                color: Theme.of(context).colorScheme.surface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: PopupMenuButton<_HomeMenuAction>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                    onSelected: (action) {
                      switch (action) {
                        case _HomeMenuAction.dashboard:
                          context.push('/dashboard');
                        case _HomeMenuAction.settings:
                          context.push('/settings');
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _HomeMenuAction.dashboard,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.query_stats_outlined),
                          title: Text(l10n.dashboard),
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: _HomeMenuAction.settings,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.settings_outlined),
                          title: Text(l10n.settings),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ViewSwitcher(
                      selected: _view,
                      onSelected: (value) => setState(() => _view = value),
                    ),
                    const SizedBox(width: 10),
                    _RoundButton(
                      icon: Icons.add_rounded,
                      foreground: Colors.white,
                      background: const Color(0xFF5B52ED),
                      tooltip: l10n.newHabit,
                      onTap: _showCreate,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _HomeMenuAction { dashboard, settings }

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.foreground,
    this.background,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      color: background ?? Theme.of(context).colorScheme.surfaceContainer,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(icon, color: foreground),
        ),
      ),
    ),
  );
}
