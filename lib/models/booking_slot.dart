class BookingSlot {
  final String time;
  final int capacity;
  int booked;

  BookingSlot(this.time, this.capacity) : booked = 0;

  bool canBook() => booked < capacity;

  void book() {
    if (canBook()) {
      booked++;
    } else {
      throw Exception('Slot is full');
    }
  }
}
