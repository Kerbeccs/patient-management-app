import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Add logout functionality later
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
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
                // Add upload report functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload Report - Coming Soon')),
                );
              },
            ),
            _buildMenuCard(
              context,
              'Book Appointment',
              Icons.calendar_today,
              Colors.green,
              () {
                // Add book appointment functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Book Appointment - Coming Soon')),
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
}
