import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import '../../models/report_model.dart';
import 'package:intl/intl.dart';

class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String searchQuery = '';
  List<UserModel> allPatients = [];
  List<UserModel> filteredPatients = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final patients = await _databaseService.getAllPatients();
      setState(() {
        allPatients = patients;
        filteredPatients = patients;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load patients: $e';
        isLoading = false;
      });
    }
  }

  void _filterPatients(String query) {
    setState(() {
      searchQuery = query;
      filteredPatients = allPatients.where((patient) {
        return patient.patientName
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            patient.email.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Records'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterPatients,
              decoration: InputDecoration(
                labelText: 'Search Patients',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Text(error!,
                            style: const TextStyle(color: Colors.red)))
                    : filteredPatients.isEmpty
                        ? const Center(child: Text('No patients found'))
                        : ListView.builder(
                            itemCount: filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = filteredPatients[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                        patient.patientName[0].toUpperCase()),
                                  ),
                                  title: Text(patient.patientName),
                                  subtitle: Text(patient.email),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PatientDetailsScreen(
                                                patient: patient),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class PatientDetailsScreen extends StatefulWidget {
  final UserModel patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.patientName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    _buildInfoRow('Name', widget.patient.patientName),
                    _buildInfoRow('Email', widget.patient.email),
                    _buildInfoRow('Phone', widget.patient.phoneNumber),
                    _buildInfoRow('Age', '${widget.patient.age} years'),
                    if (widget.patient.lastVisited != null)
                      _buildInfoRow(
                        'Last Visit',
                        DateFormat('MMM d, yyyy')
                            .format(widget.patient.lastVisited!),
                      ),
                    if (widget.patient.problemDescription != null)
                      _buildInfoRow(
                          'Problem', widget.patient.problemDescription!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Uploaded Reports',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<ReportModel>>(
              future: _databaseService.getPatientReports(widget.patient.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(snapshot.error.toString(),
                          style: const TextStyle(color: Colors.red)));
                } else if (snapshot.data?.isEmpty ?? true) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No reports uploaded yet'),
                    ),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final report = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.description),
                          title: Text('Report ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(report.description),
                              Text(
                                'Uploaded: ${DateFormat('MMM d, yyyy').format(report.uploadedAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppBar(
                                        title: const Text('Report Image'),
                                        leading: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ),
                                      Image.network(
                                        report.fileUrl,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return const CircularProgressIndicator();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.refresh),
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
            width: 100,
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
}
