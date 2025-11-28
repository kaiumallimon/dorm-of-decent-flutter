import 'package:intl/intl.dart';

class DatetimeUtil {
  // formatted date(today):
  // output: Friday, December 31, 2021
  static String getFormattedDateToday() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d, y');
    return formatter.format(now);
  }
}