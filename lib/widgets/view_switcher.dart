import 'package:flutter/material.dart';

class ViewSwitcher extends StatelessWidget {
  const ViewSwitcher({
    super.key,
    required this.selected,
    required this.onSelected,
  });
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 16,
    shadowColor: Colors.black.withValues(alpha: 0.35),
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(32),
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(context, 0, Icons.grid_view_rounded),
          _item(context, 1, Icons.checklist_rounded),
          _item(context, 2, Icons.view_week_outlined),
        ],
      ),
    ),
  );

  Widget _item(BuildContext context, int index, IconData icon) => InkWell(
    borderRadius: BorderRadius.circular(28),
    onTap: () => onSelected(index),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 54,
      height: 50,
      decoration: BoxDecoration(
        color: selected == index
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon),
    ),
  );
}
