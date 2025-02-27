import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodels.dart';
import '../views/booking_screen.dart';
import '../views/upload_report_screen.dart';
import '../../viewmodels/ticket_view_model.dart';
import '../widgets/appointment_ticket.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add character image at the top
            Image.asset(
              isDarkMode
                  ? 'assets/logos/Chibi_Doctor_Character_Joyfully_Jumping_On_Black_Background-removebg-preview.png'
                  : 'assets/logos/Chibi_Anime_Doctor_Character_Jumping_With_Joyful_Expression-removebg-preview.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildMenuCard(
                    context,
                    'Upload Report',
                    Icons.upload_file,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UploadReportScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Book Appointment',
                    Icons.calendar_today,
                    Colors.green,
                    () {
                      // Navigate to BookingScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BookingScreen()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Feedback',
                    Icons.feedback,
                    Colors.orange,
                    () {
                      // Add feedback functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feedback - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Edit Profile',
                    Icons.person_outline,
                    Colors.purple,
                    () {
                      // Add edit profile functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Edit Profile - Coming Soon')),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'View Ticket',
                    Icons.confirmation_number_outlined,
                    Colors.amber,
                    () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25.0)),
                        ),
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => TicketViewModel(
                            userId: context
                                    .read<AuthViewModel>()
                                    .currentUser
                                    ?.uid ??
                                '',
                          ),
                          child: const AppointmentTicket(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
