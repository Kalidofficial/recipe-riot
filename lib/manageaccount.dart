import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageAccountPage extends StatefulWidget {
  @override
  _ManageAccountPageState createState() => _ManageAccountPageState();
}

class _ManageAccountPageState extends State<ManageAccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _deleteEmailController = TextEditingController();
  final TextEditingController _deletePasswordController = TextEditingController();

  User? user;
  int _selectedSection = 0; // 0: Change Password, 1: Delete Account

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  Future<void> changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final email = user?.email;
    final credential = EmailAuthProvider.credential(email: email!, password: currentPassword);

    try {
      await user?.reauthenticateWithCredential(credential);
      await user?.updatePassword(_newPasswordController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating password: $e')));
    }
  }

  Future<void> deleteAccount() async {
    final email = _deleteEmailController.text;
    final password = _deletePasswordController.text;

    final cred = EmailAuthProvider.credential(email: email, password: password);

    try {
      await user?.reauthenticateWithCredential(cred);
      await user?.delete();
      await _auth.signOut(); // Log out after deletion
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account deleted successfully')));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
    }
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteAccount();
              },
              child: Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Account'),
        backgroundColor: Colors.red.shade800,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ToggleButtons(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Change Password'),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Delete Account'),
                    ),
                  ],
                  isSelected: [
                    _selectedSection == 0,
                    _selectedSection == 1,
                  ],
                  onPressed: (int index) {
                    setState(() {
                      _selectedSection = index;
                    });
                  },
                  color: Colors.black,
                  selectedColor: Colors.white,
                  fillColor: Colors.red.shade800,
                  borderColor: Colors.red.shade800,
                  selectedBorderColor: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
              ],
            ),
            SizedBox(height: 20),

            // Conditional Display
            if (_selectedSection == 0) ...[
              // Change Password Section
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                ),
                child: Text('Update Password', style: TextStyle(color: Colors.white)),
              ),
            ] else if (_selectedSection == 1) ...[
              // Delete Account Section
              TextField(
                controller: _deleteEmailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _deletePasswordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: showDeleteConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                ),
                child: Text('Delete Account', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
