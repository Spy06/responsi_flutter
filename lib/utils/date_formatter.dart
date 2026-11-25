class DateFormatter {
  const DateFormatter._();

  static const List<String> _daysFull = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _daysShort = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _monthsFull = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String formatFullDateTime(DateTime dt) {
    final dayName = _daysFull[dt.weekday - 1];
    final monthName = _monthsFull[dt.month - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$dayName, ${dt.day} $monthName ${dt.year} • $hour:$minute';
  }

  static String formatForecastDay(DateTime date, {required int index}) {
    if (index == 0) return 'Hari Ini';
    if (index == 1) return 'Besok';
    return _daysFull[date.weekday - 1];
  }

  static String formatShortDate(DateTime date) {
    final dayShort = _daysShort[date.weekday - 1];
    final monthShort = _monthsShort[date.month - 1];
    return '$dayShort, ${date.day} $monthShort';
  }
}
