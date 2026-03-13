import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now().toUtc(); 
    final diff = now.difference(date);

    if (diff.inDays < 7) { 
      return DateFormat('MMM d, yyyy').format(date);
    } else if (diff.inDays > 0) {
      return '${diff.inDays}dago'; 
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}