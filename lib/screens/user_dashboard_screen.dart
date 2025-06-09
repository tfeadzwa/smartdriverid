import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import 'id_card_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  static final List<Widget> _pages = <Widget>[
    _HomePage(),
    _MyIDPage(),
    _HistoryPage(),
    _ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 6,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder:
            (context, child) => Opacity(
              opacity: _fadeAnimation.value,
              child: _pages[_selectedIndex],
            ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'My ID'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String? name;
  String? email;
  String? role;
  String? licenseClass;
  String? licenseExpiryDate;
  File? image;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('current_user');
    if (currentUser != null) {
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final List<dynamic> users = jsonDecode(usersJson);
        final user = users.firstWhere(
          (u) => u['identifier'] == currentUser,
          orElse: () => null,
        );
        if (user != null) {
          setState(() {
            email = user['identifier'];
            role = user['role'];
            name = user['name'] ?? '';
          });
        }
      }
      // Load driver ID info
      final idJson = prefs.getString('driver_id_${currentUser}');
      if (idJson != null) {
        final data = jsonDecode(idJson);
        setState(() {
          licenseClass = data['licenseClass'];
          licenseExpiryDate = data['licenseExpiryDate'];
          image = data['imagePath'] != null ? File(data['imagePath']) : null;
        });
      }
    }
  }

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
                      backgroundImage:
                          image != null
                              ? FileImage(image!)
                              : const AssetImage(
                                    'assets/avatar_placeholder.png',
                                  )
                                  as ImageProvider,
                      child:
                          image == null
                              ? const Icon(
                                Icons.person,
                                size: 36,
                                color: Colors.blueAccent,
                              )
                              : null,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name?.isNotEmpty == true ? name! : 'Welcome!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            email ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                          if (role != null)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Role: $role',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueAccent,
                                ),
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
                          Icons.badge,
                          color: Colors.blueAccent.shade200,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'License Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoRow('License Class', licenseClass),
                    _infoRow('Expiry Date', licenseExpiryDate),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blueAccent.shade200,
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(context, Icons.badge, 'My ID', 1),
                        _actionButton(context, Icons.history, 'History', 2),
                        _actionButton(context, Icons.person, 'Profile', 3),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Smart Driver ID keeps your credentials safe and accessible.\nDrive smart, drive safe!',
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

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    IconData icon,
    String label,
    int pageIndex,
  ) {
    return Column(
      children: [
        Ink(
          decoration: ShapeDecoration(
            color: Colors.blueAccent.withOpacity(0.12),
            shape: const CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.blueAccent, size: 28),
            onPressed: () {
              final dashboardState =
                  context.findAncestorStateOfType<_UserDashboardScreenState>();
              dashboardState?._onItemTapped(pageIndex);
            },
            tooltip: label,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
        ),
      ],
    );
  }
}

class _MyIDPage extends StatefulWidget {
  @override
  State<_MyIDPage> createState() => _MyIDPageState();
}

class _MyIDPageState extends State<_MyIDPage> {
  String? name;
  String? dob;
  String? address;
  String? nationalId;
  String? licenseClass;
  String? licenseIssueDate;
  String? licenseExpiryDate;
  String? endorsements;
  File? image;
  String? userId; // unique identifier for the logged-in user

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // Assume the identifier (email) is saved as 'current_user' on login
    final id = prefs.getString('current_user');
    if (id != null) {
      userId = id;
      await _loadID();
    }
  }

  Future<void> _loadID() async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final idJson = prefs.getString('driver_id_${userId!}');
    if (idJson != null) {
      final data = jsonDecode(idJson);
      setState(() {
        name = data['name'];
        dob = data['dob'];
        address = data['address'];
        nationalId = data['nationalId'];
        licenseClass = data['licenseClass'];
        licenseIssueDate = data['licenseIssueDate'];
        licenseExpiryDate = data['licenseExpiryDate'];
        endorsements = data['endorsements'];
        image = data['imagePath'] != null ? File(data['imagePath']) : null;
      });
    } else {
      setState(() {
        name = null;
        dob = null;
        address = null;
        nationalId = null;
        licenseClass = null;
        licenseIssueDate = null;
        licenseExpiryDate = null;
        endorsements = null;
        image = null;
      });
    }
  }

  Future<void> _saveID() async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'driver_id_${userId!}',
      jsonEncode({
        'name': name,
        'dob': dob,
        'address': address,
        'nationalId': nationalId,
        'licenseClass': licenseClass,
        'licenseIssueDate': licenseIssueDate,
        'licenseExpiryDate': licenseExpiryDate,
        'endorsements': endorsements,
        'imagePath': image?.path,
      }),
    );
  }

  Future<void> _deleteID() async {
    if (userId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Driver ID'),
            content: const Text(
              'Are you sure you want to delete your driver ID? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('driver_id_${userId!}');
      setState(() {
        name = null;
        dob = null;
        address = null;
        nationalId = null;
        licenseClass = null;
        licenseIssueDate = null;
        licenseExpiryDate = null;
        endorsements = null;
        image = null;
      });
    }
  }

  Future<void> _editID() async {
    File? newImage = image;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final nameCtrl = TextEditingController(text: name ?? '');
        final dobCtrl = TextEditingController(text: dob ?? '');
        final addressCtrl = TextEditingController(text: address ?? '');
        final nationalIdCtrl = TextEditingController(text: nationalId ?? '');
        final licenseClassCtrl = TextEditingController(
          text: licenseClass ?? '',
        );
        final licenseIssueDateCtrl = TextEditingController(
          text: licenseIssueDate ?? '',
        );
        final licenseExpiryDateCtrl = TextEditingController(
          text: licenseExpiryDate ?? '',
        );
        final endorsementsCtrl = TextEditingController(
          text: endorsements ?? '',
        );
        return StatefulBuilder(
          builder:
              (context, setStateDialog) => AlertDialog(
                title: const Text('Edit Driver ID'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picked = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              newImage = File(picked.path);
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              newImage != null ? FileImage(newImage!) : null,
                          child:
                              newImage == null
                                  ? const Icon(Icons.camera_alt, size: 40)
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                        ),
                      ),
                      TextField(
                        controller: dobCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                        ),
                      ),
                      TextField(
                        controller: addressCtrl,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                      TextField(
                        controller: nationalIdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'National ID/Passport',
                        ),
                      ),
                      TextField(
                        controller: licenseClassCtrl,
                        decoration: const InputDecoration(
                          labelText: 'License Class',
                        ),
                      ),
                      TextField(
                        controller: licenseIssueDateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'License Issue Date',
                        ),
                      ),
                      TextField(
                        controller: licenseExpiryDateCtrl,
                        decoration: const InputDecoration(
                          labelText: 'License Expiry Date',
                        ),
                      ),
                      TextField(
                        controller: endorsementsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Endorsements',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'name': nameCtrl.text,
                        'dob': dobCtrl.text,
                        'address': addressCtrl.text,
                        'nationalId': nationalIdCtrl.text,
                        'licenseClass': licenseClassCtrl.text,
                        'licenseIssueDate': licenseIssueDateCtrl.text,
                        'licenseExpiryDate': licenseExpiryDateCtrl.text,
                        'endorsements': endorsementsCtrl.text,
                        'image': newImage,
                      });
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
        );
      },
    );
    if (result != null) {
      setState(() {
        name = result['name'] ?? name;
        dob = result['dob'] ?? dob;
        address = result['address'] ?? address;
        nationalId = result['nationalId'] ?? nationalId;
        licenseClass = result['licenseClass'] ?? licenseClass;
        licenseIssueDate = result['licenseIssueDate'] ?? licenseIssueDate;
        licenseExpiryDate = result['licenseExpiryDate'] ?? licenseExpiryDate;
        endorsements = result['endorsements'] ?? endorsements;
        image = result['image'] ?? image;
      });
      await _saveID();
    }
  }

  Future<void> _generateID() async {
    if (userId == null) {
      // Try to get userId again if not set
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('current_user');
      if (id != null) {
        setState(() {
          userId = id;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No logged in user found. Please log in again.'),
          ),
        );
        return;
      }
    }
    setState(() {
      name = 'John Doe';
      dob = '1990-01-01';
      address = '123 Main St';
      nationalId = 'A1234567';
      licenseClass = 'Class 4';
      licenseIssueDate = '2020-01-01';
      licenseExpiryDate = '2030-01-01';
      endorsements = 'None';
      image = File('assets/avatar_placeholder.png');
    });
    await _saveID();
  }

  @override
  Widget build(BuildContext context) {
    final hasID =
        name != null &&
        dob != null &&
        address != null &&
        nationalId != null &&
        licenseClass != null &&
        licenseIssueDate != null &&
        licenseExpiryDate != null;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child:
            hasID
                ? Stack(
                  children: [
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.blue.shade100,
                              backgroundImage:
                                  image != null
                                      ? FileImage(image!)
                                      : const AssetImage(
                                            'assets/avatar_placeholder.png',
                                          )
                                          as ImageProvider,
                              child:
                                  image == null
                                      ? const Icon(
                                        Icons.person,
                                        size: 48,
                                        color: Colors.white70,
                                      )
                                      : null,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              name ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _infoRow(Icons.cake, 'Date of Birth', dob ?? ''),
                            _infoRow(Icons.home, 'Address', address ?? ''),
                            const SizedBox(height: 16),
                            Divider(
                              thickness: 1,
                              color: Colors.blueGrey.shade100,
                            ),
                            const SizedBox(height: 8),
                            _infoRow(
                              Icons.badge,
                              'National ID/Passport',
                              nationalId ?? '',
                            ),
                            _infoRow(
                              Icons.class_,
                              'License Class',
                              licenseClass ?? '',
                            ),
                            _infoRow(
                              Icons.date_range,
                              'Issue Date',
                              licenseIssueDate ?? '',
                            ),
                            _infoRow(
                              Icons.event,
                              'Expiry Date',
                              licenseExpiryDate ?? '',
                            ),
                            if ((endorsements ?? '').isNotEmpty)
                              _infoRow(
                                Icons.verified,
                                'Endorsements',
                                endorsements ?? '',
                              ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.credit_card),
                              label: const Text('View Official Card'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (name != null &&
                                    dob != null &&
                                    address != null &&
                                    nationalId != null &&
                                    licenseClass != null &&
                                    licenseIssueDate != null &&
                                    licenseExpiryDate != null &&
                                    image != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => IDCardScreen(
                                            name: name!,
                                            dob: dob!,
                                            address: address!,
                                            image: image!,
                                            nationalId: nationalId!,
                                            licenseClass: licenseClass!,
                                            licenseIssueDate: licenseIssueDate!,
                                            licenseExpiryDate:
                                                licenseExpiryDate!,
                                            endorsements: endorsements ?? '',
                                          ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 32,
                      right: 32,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            mini: true,
                            onPressed: _editID,
                            child: const Icon(Icons.edit),
                            tooltip: 'Edit ID',
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            mini: true,
                            backgroundColor: Colors.redAccent,
                            onPressed: _deleteID,
                            child: const Icon(Icons.delete),
                            tooltip: 'Delete ID',
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.badge, size: 60, color: Colors.blueAccent),
                        const SizedBox(height: 18),
                        const Text(
                          'No Driver ID Found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Generate your digital driver ID to get started.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: _generateID,
                          icon: const Icon(Icons.add),
                          label: const Text('Generate New Driver ID'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 28,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
    );
  }
}

class _HistoryPage extends StatelessWidget {
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
                  children: [
                    Icon(Icons.history, color: Colors.blueAccent, size: 32),
                    const SizedBox(width: 14),
                    const Text(
                      'Driving History',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(thickness: 1, color: Colors.blueGrey.shade100),
                const SizedBox(height: 10),
                _historyTile(
                  Icons.check_circle,
                  'No traffic violations',
                  '2024',
                  Colors.green,
                ),
                _historyTile(
                  Icons.warning,
                  'Speeding Ticket',
                  '2023 - Paid',
                  Colors.orange,
                ),
                _historyTile(
                  Icons.check_circle,
                  'Passed Vehicle Inspection',
                  '2022',
                  Colors.green,
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Your safe driving record is your best asset!',
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

  Widget _historyTile(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.blueGrey),
        ),
      ),
    );
  }
}

class _ProfilePage extends StatefulWidget {
  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  String? email;
  String? role;
  File? image;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('current_user');
    if (currentUser != null) {
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final List<dynamic> users = jsonDecode(usersJson);
        final user = users.firstWhere(
          (u) => u['identifier'] == currentUser,
          orElse: () => null,
        );
        if (user != null) {
          setState(() {
            email = user['identifier'];
            role = user['role'];
          });
        }
      }
      // Load driver ID image if available
      final idJson = prefs.getString('driver_id_${currentUser}');
      if (idJson != null) {
        final data = jsonDecode(idJson);
        setState(() {
          image = data['imagePath'] != null ? File(data['imagePath']) : null;
        });
      }
    }
  }

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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage:
                      image != null
                          ? FileImage(image!)
                          : const AssetImage('assets/avatar_placeholder.png')
                              as ImageProvider,
                  child:
                      image == null
                          ? const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white70,
                          )
                          : null,
                ),
                const SizedBox(height: 20),
                Text(
                  email ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Role: ${role ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Divider(thickness: 1, color: Colors.blueGrey.shade100),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blueAccent),
                  title: Text(
                    email ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                // Add more user info here if available
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('current_user');
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Keep your profile up to date for a better experience.',
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
