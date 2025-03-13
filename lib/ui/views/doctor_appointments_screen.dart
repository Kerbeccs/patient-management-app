import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/doctor_appointments_view_model.dart';
import '../../models/user_model.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("Building DoctorAppointmentsScreen");
    return ChangeNotifierProvider(
      create: (_) {
        print("Creating DoctorAppointmentsViewModel");
        final viewModel = DoctorAppointmentsViewModel();
        viewModel.initialize();
        return viewModel;
      },
      child: Consumer<DoctorAppointmentsViewModel>(
        builder: (context, viewModel, child) {
          print("Building DoctorAppointmentsScreen UI with viewModel");
          print("Error message: ${viewModel.errorMessage}");
          print("Is loading: ${viewModel.isLoading}");
          print("Selected date: ${viewModel.selectedDate}");
          print("Appointments count: ${viewModel.appointmentsForDate.length}");

          return Scaffold(
            appBar: AppBar(
              title: const Text('Appointments'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    print("Refreshing appointments");
                    if (viewModel.selectedDate != null) {
                      viewModel.selectDate(viewModel.selectedDate!);
                    }
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Date Selection
                _buildDateSelection(context, viewModel),

                // Appointments List
                _buildAppointmentsList(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelection(
      BuildContext context, DoctorAppointmentsViewModel viewModel) {
    print(
        "Building date selection with ${viewModel.availableDates.length} dates");
    print("Selected date: ${viewModel.selectedDate}");

    return Padding(
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
                final isSelected = viewModel.selectedDate?.day == date.day &&
                    viewModel.selectedDate?.month == date.month &&
                    viewModel.selectedDate?.year == date.year;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.green : null,
                    ),
                    onPressed: () {
                      print(
                          "Date selected: ${DateFormat('yyyy-MM-dd').format(date)}");
                      viewModel.selectDate(date);
                    },
                    child: Text(DateFormat('MMM d').format(date)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(
      BuildContext context, DoctorAppointmentsViewModel viewModel) {
    print("Building appointments list");
    print("isLoading: ${viewModel.isLoading}");
    print("errorMessage: ${viewModel.errorMessage}");
    print("appointmentsForDate count: ${viewModel.appointmentsForDate.length}");

    if (viewModel.isLoading) {
      print("Showing loading indicator");
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.errorMessage != null) {
      print("Showing error message: ${viewModel.errorMessage}");
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Error loading appointments',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  print("Trying again");
                  if (viewModel.selectedDate != null) {
                    viewModel.selectDate(viewModel.selectedDate!);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.appointmentsForDate.isEmpty) {
      print("No appointments for date: ${viewModel.selectedDate}");
      return const Expanded(
        child: Center(
          child: Text('No appointments for this date'),
        ),
      );
    }

    print("Showing ${viewModel.appointmentsForDate.length} appointments");
    return Expanded(
      child: ListView.builder(
        itemCount: viewModel.appointmentsForDate.length,
        itemBuilder: (context, index) {
          final patient = viewModel.appointmentsForDate[index];
          print(
              "Building appointment card for index $index: ${patient.patientName}");
          return _buildAppointmentCard(context, patient, viewModel);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, UserModel patient,
      DoctorAppointmentsViewModel viewModel) {
    print(
        "Building appointment card for patient: ${patient.patientName} (${patient.uid})");
    print("Patient userType: ${patient.userType}");
    print("Patient nextVisit: ${patient.nextVisit}");
    print("Patient appointmentStatus: ${patient.appointmentStatus}");

    // Extract time from nextVisit (format: "yyyy-MM-dd HH:mm-HH:mm")
    String appointmentTime = 'Unknown time';
    if (patient.nextVisit != null && patient.nextVisit!.contains(' ')) {
      appointmentTime = patient.nextVisit!.split(' ')[1];
    }

    final bool isCompleted = patient.appointmentStatus == 'completed';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  patient.patientName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  appointmentTime,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blue,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Email', patient.email),
            _buildInfoRow('Phone', patient.phoneNumber),
            _buildInfoRow('Age', '${patient.age} years'),
            _buildInfoRow('Status', patient.appointmentStatus ?? 'pending'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: isCompleted
                      ? null
                      : () => _confirmMarkComplete(context, patient, viewModel),
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? Colors.grey : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _confirmMarkComplete(BuildContext context, UserModel patient,
      DoctorAppointmentsViewModel viewModel) async {
    print(
        "Confirming mark complete for patient: ${patient.patientName} (${patient.uid})");
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content:
            Text('Mark ${patient.patientName}\'s appointment as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    print("User confirmed: $confirmed");
    if (confirmed == true) {
      print("Marking appointment as complete");
      await viewModel.markAppointmentComplete(patient);
      if (context.mounted) {
        print("Showing success message");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${patient.patientName}\'s appointment marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
