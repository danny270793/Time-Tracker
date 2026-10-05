import '../../l10n/app_localizations.dart';

/// Short upper-case month name (e.g. `JAN` / `ENE`) for [value].
String shortMonthLabel(AppLocalizations l10n, DateTime value) =>
    l10n.monthsShort.split(',')[value.month - 1];

/// Short weekday name (e.g. `Mo` / `Lu`) for [value].
String shortWeekdayLabel(AppLocalizations l10n, DateTime value) =>
    l10n.weekdaysShort.split(',')[value.weekday - 1];

/// Short weekday names, Monday first.
List<String> shortWeekdayLabels(AppLocalizations l10n) =>
    l10n.weekdaysShort.split(',');
