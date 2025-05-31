import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import 'id_card_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _dob = '';
  String _address = '';
  String _nationalId = '';
  String _licenseClass = '';
  String _licenseIssueDate = '';
  String _licenseExpiryDate = '';
  String _endorsements = '';
  File? _image;
  final List<String> _licenseClasses = [
    'Class 2',
    'Class 4',
    'Class 5',
    'Class A',
    'Class B',
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate({required Function(String) onPicked}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      onPicked(picked.toIso8601String().split('T').first);
    }
  }

  // Validation helpers
  String? _validateNotEmpty(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your $field';
    }
    return null;
  }

  String? _validateDate(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your $field';
    }
    try {
      DateTime.parse(value);
    } catch (_) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
    return null;
  }

  String? _validateLicenseDates(String? issue, String? expiry) {
    if (issue == null || expiry == null || issue.isEmpty || expiry.isEmpty)
      return null;
    try {
      final issueDate = DateTime.parse(issue);
      final expiryDate = DateTime.parse(expiry);
      if (issueDate.isAfter(expiryDate) ||
          issueDate.isAtSameMomentAs(expiryDate)) {
        return 'Issue date must be before expiry date';
      }
    } catch (_) {}
    return null;
  }

  String? _validateDobVsIssue(String? dob, String? issue) {
    if (dob == null || issue == null || dob.isEmpty || issue.isEmpty)
      return null;
    try {
      final dobDate = DateTime.parse(dob);
      final issueDate = DateTime.parse(issue);
      if (dobDate.isAfter(issueDate) || dobDate.isAtSameMomentAs(issueDate)) {
        return 'DOB must be before license issue date';
      }
    } catch (_) {}
    return null;
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    final licenseDateError = _validateLicenseDates(
      _licenseIssueDate,
      _licenseExpiryDate,
    );
    final dobVsIssueError = _validateDobVsIssue(_dob, _licenseIssueDate);
    if (!isValid ||
        licenseDateError != null ||
        dobVsIssueError != null ||
        _image == null) {
      if (licenseDateError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(licenseDateError)));
      } else if (dobVsIssueError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(dobVsIssueError)));
      } else if (_image == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please pick a photo')));
      }
      return;
    }
    _formKey.currentState!.save();
    // Save user registration data persistently
    final registered = await AuthService.register(
      _name,
      _licenseIssueDate, // using license issue date as password for demo, replace as needed
      'Driver',
    );
    if (!registered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This user is already registered.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => IDCardScreen(
              name: _name,
              dob: _dob,
              address: _address,
              image: _image!,
              nationalId: _nationalId,
              licenseClass: _licenseClass,
              licenseIssueDate: _licenseIssueDate,
              licenseExpiryDate: _licenseExpiryDate,
              endorsements: _endorsements,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register for Driver ID')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => _validateNotEmpty(v, 'name'),
                onSaved: (v) => _name = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                controller: TextEditingController(text: _dob),
                readOnly: true,
                onTap:
                    () => _pickDate(
                      onPicked: (date) => setState(() => _dob = date),
                    ),
                validator: (v) => _validateDate(v, 'date of birth'),
                onSaved: (v) => _dob = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => _validateNotEmpty(v, 'address'),
                onSaved: (v) => _address = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'National ID / Passport Number',
                ),
                validator:
                    (v) =>
                        _validateNotEmpty(v, 'national ID or passport number'),
                onSaved: (v) => _nationalId = v!,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Driver’s License Class',
                ),
                value: _licenseClass.isNotEmpty ? _licenseClass : null,
                items:
                    _licenseClasses
                        .map(
                          (cls) =>
                              DropdownMenuItem(value: cls, child: Text(cls)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _licenseClass = val ?? ''),
                validator: (v) => _validateNotEmpty(v, 'license class'),
                onSaved: (v) => _licenseClass = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'License Issue Date',
                ),
                controller: TextEditingController(text: _licenseIssueDate),
                readOnly: true,
                onTap:
                    () => _pickDate(
                      onPicked:
                          (date) => setState(() => _licenseIssueDate = date),
                    ),
                validator: (v) => _validateDate(v, 'license issue date'),
                onSaved: (v) => _licenseIssueDate = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'License Expiry Date',
                ),
                controller: TextEditingController(text: _licenseExpiryDate),
                readOnly: true,
                onTap:
                    () => _pickDate(
                      onPicked:
                          (date) => setState(() => _licenseExpiryDate = date),
                    ),
                validator: (v) => _validateDate(v, 'license expiry date'),
                onSaved: (v) => _licenseExpiryDate = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Endorsements & Restrictions (optional)',
                ),
                onSaved: (v) => _endorsements = v ?? '',
              ),
              const SizedBox(height: 16),
              _image == null
                  ? ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('Pick Photo'),
                  )
                  : Image.file(_image!, height: 120),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Generate ID'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
