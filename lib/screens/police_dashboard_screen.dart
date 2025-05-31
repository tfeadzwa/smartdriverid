import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PoliceDashboardScreen extends StatefulWidget {
  const PoliceDashboardScreen({super.key});

  @override
  State<PoliceDashboardScreen> createState() => _PoliceDashboardScreenState();
}

class _PoliceDashboardScreenState extends State<PoliceDashboardScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    _PoliceHomePage(),
    _PoliceSearchPage(),
    _PoliceReportsPage(), // Use the new class with globalKey
    _PoliceSettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Police Dashboard')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Reports'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _PoliceHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.blueAccent.shade100,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.local_police,
                        size: 36,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Welcome, Officer!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Role: Police',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Colors.blueAccent.shade200,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => const AlertDialog(
                                    title: Text('Scan Driver ID'),
                                    content: Text('Feature coming soon!'),
                                  ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan Driver ID'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => const AlertDialog(
                                    title: Text('Search Driver'),
                                    content: Text('Feature coming soon!'),
                                  ),
                            );
                          },
                          icon: const Icon(Icons.search),
                          label: const Text('Search Driver'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _PoliceReportsPage.globalKey.currentState
                                ?.addReport(context);
                          },
                          icon: const Icon(Icons.report),
                          label: const Text('Report Issue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'System Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Scan and verify driver IDs on the road.\n'
                      '• Search for driver records and view history.\n'
                      '• Report incidents and traffic violations.\n'
                      '• Secure, role-based access for all police features.',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Smart Driver ID empowers law enforcement for safer roads.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blueGrey.shade400,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoliceSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.search, color: Colors.blueAccent, size: 32),
                    SizedBox(width: 14),
                    Text(
                      'Search Driver',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Enter Driver Email or ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  onSubmitted: (value) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Driver Found'),
                            content: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(value),
                              subtitle: const Text(
                                'License: Class 4\nExpiry: 2030-01-01',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.report,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Report Issue',
                                onPressed: () {
                                  Navigator.pop(context);
                                  _PoliceReportsPage.globalKey.currentState
                                      ?.addReport(
                                        context,
                                        prefillDriverId: value,
                                      );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: const Text('John Doe'),
                    subtitle: const Text(
                      'License: Class 4\nExpiry: 2030-01-01',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.report, color: Colors.redAccent),
                      tooltip: 'Report Issue',
                      onPressed:
                          () => _PoliceReportsPage.globalKey.currentState
                              ?.addReport(context, prefillDriverId: 'John Doe'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PoliceReportsPage extends StatefulWidget {
  static final GlobalKey<_PoliceReportsPageState> globalKey =
      GlobalKey<_PoliceReportsPageState>();
  _PoliceReportsPage() : super(key: globalKey);
  @override
  State<_PoliceReportsPage> createState() => _PoliceReportsPageState();
}

class _PoliceReportsPageState extends State<_PoliceReportsPage> {
  List<PoliceReport> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString('police_reports');
    if (reportsJson != null) {
      final List<dynamic> decoded = jsonDecode(reportsJson);
      setState(() {
        reports = decoded.map((e) => PoliceReport.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        reports = [];
        isLoading = false;
      });
    }
  }

  Future<void> addReport(
    BuildContext context, {
    String? prefillDriverId,
  }) async {
    final report = await showReportIssueDialog(
      context,
      prefillDriverId: prefillDriverId,
    );
    if (report != null) {
      setState(() {
        reports.add(report);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'police_reports',
        jsonEncode(reports.map((e) => e.toJson()).toList()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue reported successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.report, color: Colors.blueAccent, size: 32),
                    SizedBox(width: 14),
                    Text(
                      'Reports & Violations',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (reports.isEmpty)
                  const Center(
                    child: Text(
                      'No reports found.',
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                    ),
                  )
                else
                  ...reports.map(
                    (report) => Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.warning,
                          color: Colors.orange,
                          size: 32,
                        ),
                        title: Text(
                          report.violationType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        subtitle: Text(
                          'Driver: ${report.driverId}\nDate: ${report.date}\nNotes: ${report.notes}',
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'All reported violations and fines are listed here.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PoliceSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          size: 36,
                          color: Colors.blueAccent.shade700,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Police Settings',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text('Logout'),
                      subtitle: const Text('Sign out of your police account.'),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text(
                                  'Are you sure you want to logout?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                        );
                        if (confirmed == true) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('current_user');
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blueGrey.shade400,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'App Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Smart Driver ID v1.0.0',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '© 2025 Smart Driver ID Team',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PoliceReport {
  final String driverId;
  final String violationType;
  final String date;
  final String notes;

  PoliceReport({
    required this.driverId,
    required this.violationType,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    'driverId': driverId,
    'violationType': violationType,
    'date': date,
    'notes': notes,
  };

  static PoliceReport fromJson(Map<String, dynamic> json) => PoliceReport(
    driverId: json['driverId'],
    violationType: json['violationType'],
    date: json['date'],
    notes: json['notes'],
  );
}

Future<PoliceReport?> showReportIssueDialog(
  BuildContext context, {
  String? prefillDriverId,
}) async {
  final driverIdController = TextEditingController(text: prefillDriverId ?? '');
  final notesController = TextEditingController();
  String? violationType;
  DateTime selectedDate = DateTime.now();
  final formKey = GlobalKey<FormState>();
  final types = ['Speeding', 'Unpaid Fine', 'Expired License', 'DUI', 'Other'];
  final result = await showDialog<PoliceReport>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Report Issue'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: driverIdController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Email or ID',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? 'Enter driver email or ID'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: violationType,
                    items:
                        types
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => violationType = v,
                    decoration: const InputDecoration(
                      labelText: 'Violation Type',
                    ),
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? 'Select violation type'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      prefixIcon: const Icon(Icons.date_range),
                      hintText: selectedDate.toString().split(' ')[0],
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        selectedDate = picked;
                      }
                    },
                    controller: TextEditingController(
                      text: selectedDate.toString().split(' ')[0],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(
                    context,
                    PoliceReport(
                      driverId: driverIdController.text.trim(),
                      violationType: violationType!,
                      date: selectedDate.toString().split(' ')[0],
                      notes: notesController.text.trim(),
                    ),
                  );
                }
              },
              child: const Text('Report'),
            ),
          ],
        ),
  );
  return result;
}
