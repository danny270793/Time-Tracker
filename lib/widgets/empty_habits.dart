import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class EmptyHabits extends StatelessWidget {
  const EmptyHabits({super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(AppLocalizations.of(context)!.emptyHabits));
}
