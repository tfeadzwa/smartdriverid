import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  String? adminName;
  String? adminEmail;
  File? image;
  int userCount = 0;
  int driverIdCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('current_user');
    if (currentUser != null) {
      final usersJson = prefs.getString('users');
      if (usersJson != null) {
        final List<dynamic> users = jsonDecode(usersJson);
        final admin = users.firstWhere(
          (u) => u['identifier'] == currentUser,
          orElse: () => null,
        );
        if (admin != null) {
          setState(() {
            adminEmail = admin['identifier'];
            adminName = admin['name'] ?? 'Admin';
          });
        }
        setState(() {
          userCount = users.length;
        });
      }
      // Count driver IDs
      final keys = prefs.getKeys();
      final driverIds = keys.where((k) => k.startsWith('driver_id_')).toList();
      setState(() {
        driverIdCount = driverIds.length;
      });
      // Try to load admin image from their driver ID if available
      final idJson = prefs.getString('driver_id_${currentUser}');
      if (idJson != null) {
        final data = jsonDecode(idJson);
        setState(() {
          image = data['imagePath'] != null ? File(data['imagePath']) : null;
        });
      }
    }
  }

  static final List<Widget> _pages = <Widget>[
    _AdminHomePage(),
    _AdminUsersPage(),
    _AdminDriverIDsPage(),
    _AdminSettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Driver IDs'),
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

class _AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_AdminDashboardScreenState>();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin Profile Card
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
                          state?.image != null
                              ? FileImage(state!.image!)
                              : const AssetImage(
                                    'assets/avatar_placeholder.png',
                                  )
                                  as ImageProvider,
                      child:
                          state?.image == null
                              ? const Icon(
                                Icons.admin_panel_settings,
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
                            state?.adminName?.isNotEmpty == true
                                ? state!.adminName!
                                : 'Welcome, Admin!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state?.adminEmail ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
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
                            child: const Text(
                              'Role: Admin',
                              style: TextStyle(
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
            // Statistics Card
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
                          Icons.bar_chart,
                          color: Colors.blueAccent.shade200,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Dashboard Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoRow(
                      'Total Registered Users',
                      state?.userCount.toString() ?? '-',
                    ),
                    _infoRow(
                      'Total Driver IDs',
                      state?.driverIdCount.toString() ?? '-',
                    ),
                    // Add more stats if needed
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions Card
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
                          Icons.flash_on,
                          color: Colors.orange.shade400,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
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
                            final dashboardState =
                                context
                                    .findAncestorStateOfType<
                                      _AdminDashboardScreenState
                                    >();
                            if (dashboardState != null) {
                              dashboardState._onItemTapped(1); // Users tab
                            }
                          },
                          icon: const Icon(Icons.people),
                          label: const Text('Manage Users'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final dashboardState =
                                context
                                    .findAncestorStateOfType<
                                      _AdminDashboardScreenState
                                    >();
                            if (dashboardState != null) {
                              dashboardState._onItemTapped(2); // Driver IDs tab
                            }
                          },
                          icon: const Icon(Icons.badge),
                          label: const Text('Driver IDs'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final dashboardState =
                                context
                                    .findAncestorStateOfType<
                                      _AdminDashboardScreenState
                                    >();
                            if (dashboardState != null) {
                              dashboardState._onItemTapped(3); // Settings tab
                            }
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Settings'),
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
            // System Overview Card
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
                          Icons.dashboard_customize,
                          color: Colors.blueAccent.shade200,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'System Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Manage all users, driver IDs, and system settings from one place.\n'
                      '• Real-time updates for user and driver ID management.\n'
                      '• Secure, role-based access for all system features.\n'
                      '• All actions are instantly reflected across the app.',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Welcome Message
            Center(
              child: Text(
                'Welcome to the Smart Driver ID Admin Dashboard.\nManage users and driver IDs with confidence!',
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

  Widget _infoRow(String label, String value) {
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
            child: Text(value, style: const TextStyle(color: Colors.blueGrey)),
          ),
        ],
      ),
    );
  }
}

class _AdminUsersPage extends StatefulWidget {
  @override
  State<_AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<_AdminUsersPage> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  String searchQuery = '';
  String? roleFilter;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final List<dynamic> userList = jsonDecode(usersJson);
      setState(() {
        users = userList.cast<Map<String, dynamic>>();
        _applyFilters();
        isLoading = false;
      });
    } else {
      setState(() {
        users = [];
        filteredUsers = [];
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredUsers =
          users.where((user) {
            final matchesSearch =
                searchQuery.isEmpty ||
                (user['name']?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (user['identifier']?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                    false);
            final matchesRole =
                roleFilter == null || user['role'] == roleFilter;
            return matchesSearch && matchesRole;
          }).toList();
    });
  }

  Future<void> _createUser() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? selectedRole;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New User'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email/Identifier',
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items:
                        ['Driver', 'Police', 'Organization']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => selectedRole = value,
                    decoration: const InputDecoration(labelText: 'Role'),
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
                  if (nameController.text.isNotEmpty &&
                      emailController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty &&
                      selectedRole != null) {
                    Navigator.pop(context, {
                      'name': nameController.text,
                      'identifier': emailController.text,
                      'password': passwordController.text,
                      'role': selectedRole,
                    });
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users');
      List<dynamic> userList = usersJson != null ? jsonDecode(usersJson) : [];
      // Prevent duplicate identifier
      if (userList.any((u) => u['identifier'] == result['identifier'])) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User with this identifier already exists.'),
          ),
        );
        return;
      }
      userList.add({
        'name': result['name'],
        'identifier': result['identifier'],
        'password': result['password'],
        'role': result['role'],
      });
      await prefs.setString('users', jsonEncode(userList));
      await _loadUsers();
    }
  }

  Future<void> _deleteUser(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final List<dynamic> userList = jsonDecode(usersJson);
      userList.removeWhere((u) => u['identifier'] == identifier);
      await prefs.setString('users', jsonEncode(userList));
      await prefs.remove('driver_id_$identifier');
      await _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by name or email',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                        _applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: roleFilter,
                    hint: const Text('Role'),
                    items:
                        <String?>[null, 'Driver', 'Police', 'Organization']
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role ?? 'All'),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        roleFilter = value;
                        _applyFilters();
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  filteredUsers.isEmpty
                      ? Center(
                        child: Card(
                          elevation: 8,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 60,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'No users found.',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No registered users in the system.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent.withOpacity(
                                  0.1,
                                ),
                                child: Icon(
                                  user['role'] == 'Admin'
                                      ? Icons.admin_panel_settings
                                      : user['role'] == 'Police'
                                      ? Icons.local_police
                                      : user['role'] == 'Organization'
                                      ? Icons.business
                                      : Icons.person,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              title: Text(
                                user['name'] ?? user['identifier'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${user['identifier']}\nRole: ${user['role']}',
                                style: const TextStyle(color: Colors.blueGrey),
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (user['role'] != 'Admin')
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      tooltip: 'Delete User',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Delete User',
                                                ),
                                                content: Text(
                                                  'Are you sure you want to delete \\${user['name'] ?? user['identifier']}?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.redAccent,
                                                        ),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                        );
                                        if (confirm == true) {
                                          await _deleteUser(user['identifier']);
                                        }
                                      },
                                    ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                    ),
                                    tooltip: 'Edit User',
                                    onPressed: () async {
                                      final nameController =
                                          TextEditingController(
                                            text: user['name'] ?? '',
                                          );
                                      final roleController =
                                          TextEditingController(
                                            text: user['role'] ?? '',
                                          );
                                      final result = await showDialog<
                                        Map<String, dynamic>
                                      >(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text('Edit User'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: nameController,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Name',
                                                        ),
                                                  ),
                                                  DropdownButtonFormField<
                                                    String
                                                  >(
                                                    value: user['role'],
                                                    items:
                                                        [
                                                              'Driver',
                                                              'Police',
                                                              'Organization',
                                                            ]
                                                            .map(
                                                              (role) =>
                                                                  DropdownMenuItem(
                                                                    value: role,
                                                                    child: Text(
                                                                      role,
                                                                    ),
                                                                  ),
                                                            )
                                                            .toList(),
                                                    onChanged:
                                                        (value) =>
                                                            roleController
                                                                .text = value!,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Role',
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context, {
                                                      'name':
                                                          nameController.text,
                                                      'role':
                                                          roleController
                                                                  .text
                                                                  .isNotEmpty
                                                              ? roleController
                                                                  .text
                                                              : user['role'],
                                                    });
                                                  },
                                                  child: const Text('Save'),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (result != null) {
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        final usersJson = prefs.getString(
                                          'users',
                                        );
                                        if (usersJson != null) {
                                          final List<dynamic> userList =
                                              jsonDecode(usersJson);
                                          final idx = userList.indexWhere(
                                            (u) =>
                                                u['identifier'] ==
                                                user['identifier'],
                                          );
                                          if (idx != -1) {
                                            userList[idx]['name'] =
                                                result['name'];
                                            userList[idx]['role'] =
                                                result['role'];
                                            await prefs.setString(
                                              'users',
                                              jsonEncode(userList),
                                            );
                                            await _loadUsers();
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _createUser,
              icon: const Icon(Icons.add),
              label: const Text('Add New User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
  }
}

class _AdminDriverIDsPage extends StatefulWidget {
  @override
  State<_AdminDriverIDsPage> createState() => _AdminDriverIDsPageState();
}

class _AdminDriverIDsPageState extends State<_AdminDriverIDsPage> {
  List<Map<String, dynamic>> driverIDs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDriverIDs();
  }

  Future<void> _loadDriverIDs() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson == null) {
      setState(() {
        driverIDs = [];
        isLoading = false;
      });
      return;
    }
    final List<dynamic> users = jsonDecode(usersJson);
    final ids = <Map<String, dynamic>>[];
    for (final user in users) {
      if (user['role'] == 'Driver') {
        final idJson = prefs.getString('driver_id_${user['identifier']}');
        if (idJson != null) {
          final idData = jsonDecode(idJson);
          ids.add({
            'name': user['name'] ?? '-',
            'identifier': user['identifier'],
            'licenseClass': idData['licenseClass'] ?? '-',
            'licenseExpiryDate': idData['licenseExpiryDate'] ?? '-',
            'imagePath': idData['imagePath'],
          });
        }
      }
    }
    setState(() {
      driverIDs = ids;
      isLoading = false;
    });
  }

  Future<void> _deleteDriverID(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_id_$identifier');
    await _loadDriverIDs();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (driverIDs.isEmpty) {
      return Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.badge, size: 60, color: Colors.blueAccent),
                const SizedBox(height: 20),
                const Text(
                  'No driver IDs found.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No registered driver IDs in the system.',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: driverIDs.length,
      itemBuilder: (context, index) {
        final driver = driverIDs[index];
        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ListTile(
            leading:
                driver['imagePath'] != null
                    ? CircleAvatar(
                      backgroundImage: FileImage(File(driver['imagePath'])),
                    )
                    : const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              driver['name'] ?? driver['identifier'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Email: ${driver['identifier']}\nClass: ${driver['licenseClass']}\nExpiry: ${driver['licenseExpiryDate']}',
              style: const TextStyle(color: Colors.blueGrey),
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: 'Delete Driver ID',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Delete Driver ID'),
                            content: Text(
                              'Are you sure you want to delete the driver ID for ${driver['name'] ?? driver['identifier']}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) {
                      await _deleteDriverID(driver['identifier']);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                  tooltip: 'View Details',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Driver ID Details'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: ${driver['name'] ?? '-'}'),
                                Text('Email: ${driver['identifier'] ?? '-'}'),
                                Text(
                                  'License Class: ${driver['licenseClass'] ?? '-'}',
                                ),
                                Text(
                                  'Expiry: ${driver['licenseExpiryDate'] ?? '-'}',
                                ),
                              ],
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminSettingsPage extends StatelessWidget {
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
                          'Admin Settings',
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
                        Icons.lock_reset,
                        color: Colors.blueAccent,
                      ),
                      title: const Text('Change Password'),
                      subtitle: const Text(
                        'Update your admin account password.',
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => _ChangePasswordDialog(),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text('Logout'),
                      subtitle: const Text('Sign out of your admin account.'),
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

class _ChangePasswordDialog extends StatefulWidget {
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  String _oldPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  String? _error;

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    final currentUser = prefs.getString('current_user');
    if (usersJson != null && currentUser != null) {
      final List<dynamic> users = jsonDecode(usersJson);
      final idx = users.indexWhere((u) => u['identifier'] == currentUser);
      if (idx != -1) {
        if (users[idx]['password'] != _oldPassword) {
          setState(() {
            _error = 'Old password is incorrect.';
            _isLoading = false;
          });
          return;
        }
        if (_newPassword != _confirmPassword) {
          setState(() {
            _error = 'Passwords do not match.';
            _isLoading = false;
          });
          return;
        }
        if (_newPassword.length < 6) {
          setState(() {
            _error = 'Password must be at least 6 characters.';
            _isLoading = false;
          });
          return;
        }
        users[idx]['password'] = _newPassword;
        await prefs.setString('users', jsonEncode(users));
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully.')),
        );
        return;
      }
    }
    setState(() {
      _error = 'An error occurred.';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Old Password'),
              obscureText: true,
              onChanged: (v) => _oldPassword = v,
              validator:
                  (v) => v == null || v.isEmpty ? 'Enter old password' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
              onChanged: (v) => _newPassword = v,
              validator:
                  (v) => v == null || v.isEmpty ? 'Enter new password' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
              ),
              obscureText: true,
              onChanged: (v) => _confirmPassword = v,
              validator:
                  (v) => v == null || v.isEmpty ? 'Confirm new password' : null,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () {
                    if (_formKey.currentState!.validate()) {
                      _changePassword();
                    }
                  },
          child:
              _isLoading
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Change'),
        ),
      ],
    );
  }
}
