String convertDurationToString(Duration? duration) {
  if (duration == null) return "00:00:00";
  String hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

String convertDateToString(DateTime? date) {
  if (date == null) return "";
  return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
}

String convertDateToTimeAgo(DateTime? date) {
  if (date == null) return "";
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

String capitalize(String input) {
  if (input.isEmpty) return input;
  return '${input[0].toUpperCase()}${input.substring(1)}';
}
