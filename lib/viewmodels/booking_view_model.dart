import 'package:flutter/foundation.dart';
import '../models/booking_slot.dart';
import 'package:intl/intl.dart';

class BookingViewModel extends ChangeNotifier {
  DateTime? _selectedDate;
  BookingSlot? _selectedSlot;

  // Map to store slots for each date (key: formatted date string, value: list of slots)
  final Map<String, List<BookingSlot>> _dateSlots = {};

  DateTime? get selectedDate => _selectedDate;
  BookingSlot? get selectedSlot => _selectedSlot;

  // Get slots for the currently selected date
  List<BookingSlot> get slots {
    if (_selectedDate == null) return [];

    final dateKey = _getDateKey(_selectedDate!);

    // Initialize slots for this date if they don't exist
    if (!_dateSlots.containsKey(dateKey)) {
      _dateSlots[dateKey] = [
        BookingSlot('9-10am', 6),
        BookingSlot('2:30-3:30pm', 10),
        BookingSlot('8-9pm', 10),
      ];
    }

    return _dateSlots[dateKey]!;
  }

  // Helper method to get a consistent date key
  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void setSelectedSlot(BookingSlot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  /// Returns the next 7 days as available booking dates.
  List<DateTime> get availableDates {
    final today = DateTime.now();
    return List.generate(7, (index) => today.add(Duration(days: index + 1)));
  }

  void selectDate(DateTime date) {
    if (!isDateValid(date)) {
      debugPrint('Invalid date selected: $date');
      return;
    }
    _selectedDate = date;
    notifyListeners();
  }

  bool isDateValid(DateTime date) {
    return availableDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  /// Books a slot if available, returns `true` if successful, else `false`.
  bool bookSlot(String time) {
    if (_selectedDate == null) {
      debugPrint('Error: No date selected');
      return false;
    }

    final dateKey = _getDateKey(_selectedDate!);

    try {
      // Get slots for the selected date
      final dateSlots = _dateSlots[dateKey];
      if (dateSlots == null) {
        debugPrint('Error: No slots available for selected date');
        return false;
      }

      final slot = dateSlots.firstWhere((slot) => slot.time == time);

      if (slot.canBook()) {
        slot.book();
        notifyListeners();
        return true;
      } else {
        debugPrint('Error: Slot is full');
        return false;
      }
    } catch (e) {
      debugPrint('Error: Invalid slot time ($time)');
      return false;
    }
  }
}
