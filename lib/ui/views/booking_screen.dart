import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/booking_view_model.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/booking_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/auth_viewmodels.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    print("Initializing Razorpay");
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print("Razorpay initialization complete");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final viewModel = Provider.of<BookingViewModel>(context, listen: false);
    final selectedSlot = viewModel.selectedSlot;
    final selectedDate = viewModel.selectedDate;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;

    if (selectedSlot != null && selectedDate != null && user != null) {
      // First book the slot in the booking model
      viewModel.bookSlot(selectedSlot.time);

      // Format the date for display and storage
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      try {
        // Update user database with appointment information
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'lastVisited': 'N/A',
          'nextVisit': '$formattedDate ${selectedSlot.time}',
          'appointmentStatus': 'pending'
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Payment Successful! Appointment booked for $formattedDate at ${selectedSlot.time}'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print("Error updating user data: $e");
        // Still show success for the booking part, but note the database error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Payment Successful! Slot booked, but there was an issue updating your profile.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
      ),
    );
  }

  void _initiatePayment(BookingSlot slot) async {
    // Debug payment initiation
    print("Initiating payment for slot: ${slot.time}");

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to continue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Store selected slot before payment
    Provider.of<BookingViewModel>(context, listen: false).setSelectedSlot(slot);

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Initializing payment...'),
        duration: Duration(seconds: 1),
      ),
    );

    // We'll only use hardcoded values or minimal user info for payment
    // to avoid Firestore permission issues during payment initiation
    try {
      // Create simplified options for Razorpay
      var options = {
        'key': 'rzp_test_Kt8jSnWJ7nCCwX',
        'amount': 30000, // Amount in smallest currency unit (paise)
        'name': 'Doctor Appointment',
        'description': 'Booking for ${slot.time}',
        'timeout': 300, // in seconds
        'prefill': {
          'contact': user.phoneNumber ?? '9876543210',
          'email': user.email ?? 'test@example.com',
        }
      };

      print("Opening Razorpay with options: $options");
      _razorpay.open(options);
    } catch (e) {
      print("Error in payment initiation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BookingViewModel>(context);

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
                      final isSelected = viewModel.selectedDate != null &&
                          viewModel.selectedDate!.year == date.year &&
                          viewModel.selectedDate!.month == date.month &&
                          viewModel.selectedDate!.day == date.day;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? Colors.green : null,
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(slot.time),
                      subtitle: Text(
                          'Available: ${slot.capacity - slot.booked}/${slot.capacity}'),
                      trailing: ElevatedButton(
                        onPressed: slot.canBook()
                            ? () => _initiatePayment(slot)
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
  }
}
