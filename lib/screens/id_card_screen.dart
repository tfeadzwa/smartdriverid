import 'dart:io';
import 'package:flutter/material.dart';

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
  final String? licenseNumber;
  final bool? sadcCompliant;
  final String? biometricData;

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
    this.licenseNumber,
    this.sadcCompliant,
    this.biometricData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver's License"),
        backgroundColor: Colors.white,
        elevation: 3,
        iconTheme: const IconThemeData(color: Colors.indigo),
        titleTextStyle: const TextStyle(
          color: Colors.indigo,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            width: 370,
            height: 230,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF7F7F7), Color(0xFFE0E0E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade400, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Zim flag top left
                Positioned(
                  left: 12,
                  top: 10,
                  child: Image.asset(
                    'assets/zim_flag.png',
                    width: 38,
                    height: 28,
                  ),
                ),
                // Coat of arms top right
                Positioned(
                  right: 12,
                  top: 10,
                  child: Image.asset(
                    'assets/coat_of_arms.png',
                    width: 38,
                    height: 28,
                  ),
                ),
                // Card title and subtitle
                Positioned(
                  left: 60,
                  top: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "REPUBLIC OF ZIMBABWE",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        "DRIVER'S LICENCE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[900],
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Driver photo
                Positioned(
                  left: 18,
                  top: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      width: 70,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Main details
                Positioned(
                  left: 105,
                  top: 38,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Surname:', style: _fieldLabelStyle()),
                          const SizedBox(width: 4),
                          Text(
                            name.split(' ').last.toUpperCase(),
                            style: _fieldValueStyle(),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Forenames:', style: _fieldLabelStyle()),
                          const SizedBox(width: 4),
                          Text(
                            name.split(' ').length > 1
                                ? name
                                    .split(' ')
                                    .sublist(0, name.split(' ').length - 1)
                                    .join(' ')
                                : '',
                            style: _fieldValueStyle(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text('ID No:', style: _fieldLabelStyle()),
                          const SizedBox(width: 4),
                          Text(nationalId, style: _fieldValueStyle()),
                        ],
                      ),
                      Row(
                        children: [
                          Text('DOB:', style: _fieldLabelStyle()),
                          const SizedBox(width: 4),
                          Text(dob, style: _fieldValueStyle()),
                        ],
                      ),
                      if (licenseNumber != null && licenseNumber!.isNotEmpty)
                        Row(
                          children: [
                            Text('Licence #:', style: _fieldLabelStyle()),
                            const SizedBox(width: 4),
                            Text(licenseNumber!, style: _fieldValueStyle()),
                          ],
                        ),
                      Row(
                        children: [
                          Text('Class:', style: _fieldLabelStyle()),
                          const SizedBox(width: 4),
                          Text(licenseClass, style: _fieldValueStyle()),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Issued:', style: _fieldLabelStyle()),
                          const SizedBox(width: 4),
                          Text(licenseIssueDate, style: _fieldValueStyle()),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Expiry:', style: _fieldLabelStyle()),
                          const SizedBox(width: 4),
                          Text(licenseExpiryDate, style: _fieldValueStyle()),
                        ],
                      ),
                      if (sadcCompliant != null)
                        Row(
                          children: [
                            Text('SADC:', style: _fieldLabelStyle()),
                            const SizedBox(width: 4),
                            Text(
                              sadcCompliant! ? 'Yes' : 'No',
                              style: _fieldValueStyle(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Endorsements and biometric data (bottom right)
                Positioned(
                  right: 16,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (endorsements.isNotEmpty)
                        Text(
                          'Endorsements: $endorsements',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        ),
                      if (biometricData != null && biometricData!.isNotEmpty)
                        Text(
                          'Biometric: $biometricData',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _fieldLabelStyle() {
    return const TextStyle(
      fontSize: 12,
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle _fieldValueStyle() {
    return const TextStyle(
      fontSize: 12,
      color: Colors.black87,
      fontWeight: FontWeight.w400,
    );
  }
}
