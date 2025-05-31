import 'package:flutter/material.dart';
import 'dart:io';

class IDCardScreen extends StatelessWidget {
  final String name;
  final String dob;
  final String address;
  final File image;
  final String nationalId;
  final String licenseClass;
  final String licenseIssueDate;
  final String licenseExpiryDate;
  final String endorsements;

  const IDCardScreen({
    super.key,
    required this.name,
    required this.dob,
    required this.address,
    required this.image,
    required this.nationalId,
    required this.licenseClass,
    required this.licenseIssueDate,
    required this.licenseExpiryDate,
    required this.endorsements,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Driver ID')),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(image, height: 100),
                const SizedBox(height: 16),
                Text('Name: $name'),
                Text('DOB: $dob'),
                Text('Address: $address'),
                Text('National ID/Passport: $nationalId'),
                Text('License Class: $licenseClass'),
                Text('Issue Date: $licenseIssueDate'),
                Text('Expiry Date: $licenseExpiryDate'),
                if (endorsements.isNotEmpty)
                  Text('Endorsements: $endorsements'),
                const SizedBox(height: 16),
                const Text('ID: 1234567890'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
