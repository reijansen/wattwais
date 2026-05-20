//converts a monthId string (ex. "2026-05" to "May 2026")
String formatMonth(String monthId) {
  final parts = monthId.split('-');

  final year = parts[0];
  final month = int.tryParse(parts[1]) ?? 1;

  const months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];

  //month is within 1–12
  if (month < 1 || month > 12) return monthId;

  return '${months[month - 1]} $year';
}