import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/booking_view_model.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingViewModel(),
      child: Consumer<BookingViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Book Appointment'),
            ),
            body: Column(
              children: [
                // Date Selection
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: viewModel.availableDates.map((date) {
                            final isSelected =
                                viewModel.selectedDate?.day == date.day;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isSelected ? Colors.green : null,
                                ),
                                onPressed: () => viewModel.selectDate(date),
                                child: Text(DateFormat('MMM d').format(date)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Time Slots
                if (viewModel.selectedDate != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Available Slots:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.slots.length,
                      itemBuilder: (context, index) {
                        final slot = viewModel.slots[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(slot.time),
                            subtitle: Text(
                                'Available: ${slot.capacity - slot.booked}/${slot.capacity}'),
                            trailing: ElevatedButton(
                              onPressed: slot.canBook()
                                  ? () {
                                      try {
                                        viewModel.bookSlot(slot.time);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Booking successful for ${slot.time} on ${DateFormat('MMM d').format(viewModel.selectedDate!)}'),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    }
                                  : null,
                              child: const Text('Book'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
