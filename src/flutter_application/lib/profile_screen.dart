// Import required packages
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

// ProfileScreen Stateful Widget
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

// ProfileScreen State
class _ProfileScreenState extends State<ProfileScreen> {
  // User's profile details
  String name = "John Doe";
  int age = 30;
  String occupation = "Engineer";
  int height = 170;
  double weight = 65.0;

  // Define the isLoading method
  set isLoading(bool isLoading) {}

  // Define a method to show edit dialog
  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create local copies of the profile details
        String _name = name;
        int _age = age;
        String _occupation = occupation;
        int _height = height;
        double _weight = weight;

        // Build the AlertDialog
        return AlertDialog(
          title: Text(
            'Edit Profile',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Name:', _name, (value) => _name = value),
                _buildNumberField('Age:', _age, (value) => _age = int.tryParse(value) ?? age),
                _buildTextField('Occupation:', _occupation, (value) => _occupation = value),
                _buildNumberField('Height (cm):', _height, (value) => _height = int.tryParse(value) ?? height),
                _buildNumberField('Weight (kg):', _weight, (value) => _weight = double.tryParse(value) ?? weight),
              ],
            ),
          ),
          actions: _buildDialogActions(context, _name, _age, _occupation, _height, _weight),
        );
      },
    );
  }

  // Function to build text field with label
  Widget _buildTextField(String label, String initialValue, Function onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  // Function to build number field with label
  Widget _buildNumberField(String label, num initialValue, Function onChanged) {
    return _buildTextField(label, initialValue.toString(), onChanged);
  }

  // Function to build dialog actions
  List<Widget> _buildDialogActions(BuildContext context, String _name, int _age, String _occupation, int _height, double _weight) {
    return [
      TextButton(
        child: Text(
          'Cancel',
          style: GoogleFonts.poppins(),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      TextButton(
        child: Text(
          'Save',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          setState(() {
            isLoading = true;
          });

          // Simulate saving the changes for 2 seconds
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              name = _name;
              age = _age;
              occupation = _occupation;
              height = _height;
              weight = _weight;

              isLoading = false;
            });

            Navigator.of(context).pop();
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 32.0),
            Icon(Icons.person_rounded, size: 175, color: Colors.black54),
            SizedBox(height: 16.0),
            _buildProfileDetail(name, 28.0, FontWeight.bold),
            SizedBox(height: 8.0),
            _buildProfileDetail("$age years old, $occupation", 18.0, null, Colors.grey[600]),
            SizedBox(height: 16.0),
            Divider(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileDetail("Height:", 18.0, FontWeight.bold),
                  SizedBox(height: 8.0),
                  _buildProfileDetail("$height cm", 18.0, null, Colors.grey[600]),
                  SizedBox(height: 16.0),
                  _buildProfileDetail("Weight:", 18.0, FontWeight.bold),
                  SizedBox(height: 8.0),
                  _buildProfileDetail("$weight kg", 18.0, null, Colors.grey[600]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build a profile detail
  Widget _buildProfileDetail(String text, double fontSize, FontWeight fontWeight, [Color color = Colors.black]) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
