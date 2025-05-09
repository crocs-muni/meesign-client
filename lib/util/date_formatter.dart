String formatDate(int millisecondsSinceEpoch) {
  // Format like 24 Feb 2023, 18:00
  final date = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

  const monthNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  final day = date.day.toString();
  final month = monthNames[date.month - 1];
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day. $month $year, $hour:$minute';
}
