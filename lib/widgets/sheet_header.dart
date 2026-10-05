import 'package:flutter/material.dart';

class SheetHeader extends StatelessWidget {
  const SheetHeader(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const BackButtonIcon(),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        // Balances the leading icon button so the title stays centered.
        const SizedBox(width: 48),
      ],
    ),
  );
}
