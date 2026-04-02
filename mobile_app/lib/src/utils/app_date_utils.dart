String formatAppDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day-$month-${value.year}';
}

DateTime? parseAppDate(String value) {
  final match = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(value.trim());
  if (match == null) {
    return null;
  }

  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final parsed = DateTime(year, month, day);

  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    return null;
  }

  return parsed;
}

String formatMonthKey(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  return '${value.year}-$month';
}

String formatMonthForDisplay(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(value.trim());
  if (match == null) {
    return value;
  }

  return '${match.group(2)!}-${match.group(1)!}';
}
