import 'package:flutter/foundation.dart';
import '../models/booking_slot.dart';

class BookingViewModel extends ChangeNotifier {
  DateTime? selectedDate;
  final List<BookingSlot> slots = [
    BookingSlot('9-10am', 6),
    BookingSlot('2:30-3:30pm', 10),
    BookingSlot('8-9pm', 10),
  ];

  List<DateTime> get availableDates {
    final today = DateTime.now();
    return List.generate(
        4, (index) => DateTime(today.year, today.month, today.day + index + 1));
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  bool isDateValid(DateTime date) {
    return availableDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  void bookSlot(String time) {
    if (selectedDate == null) {
      throw Exception('Please select a date first');
    }

    final slot = slots.firstWhere(
      (slot) => slot.time == time,
      orElse: () => throw Exception('Invalid slot time'),
    );

    if (slot.canBook()) {
      slot.book();
      notifyListeners();
    } else {
      throw Exception('Slot is full');
    }
  }
}
