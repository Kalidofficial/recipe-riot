import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authmanagement/authmanage.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Authmanage _authManage = Authmanage();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  bool _isLoginPasswordVisible = false;
  bool _isRegisterPasswordVisible = false;
  bool _keepMeLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLoginStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  // Load login status
  Future<void> _loadLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('loggedIn') ?? false;

    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/home', arguments: {
        'username': prefs.getString('username'),
      });
    }
  }

  Future<void> _login() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog('Please enter your email.');
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog('Please enter your password.');
      return;
    }

    String? result = await _authManage.signIn(email, password);

    if (result != null && result == 'Sign in successful') {
      if (_keepMeLoggedIn) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('loggedIn', true);
        await prefs.setString('username', email);
      }
      Navigator.pushReplacementNamed(context, '/home', arguments: {'username': email});
    } else {
      _showErrorDialog(result ?? 'Your email or password is incorrect. Please recheck and try again.');
    }
  }

  Future<void> _register() async {
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog('Please enter your email.');
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog('Please enter your password.');
      return;
    }

    String? result = await _authManage.signUp(email, password);

    if (result != null && result == 'Registration successful. Please verify your email address.') {
      _showInfoDialog(result, () {
        Navigator.pop(context);
        _tabController.index = 0; // Switch to login tab
      });
    } else {
      _showErrorDialog(result ?? 'Failed to register. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(String message, VoidCallback onOk) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notice'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: onOk,
              child: Text('OK'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Spacer(flex: 5),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTabs(),
                      Expanded(child: _buildTabViews()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tabs for login and registration
  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      tabs: [
        Tab(text: 'Login'),
        Tab(text: 'Register'),
      ],
      isScrollable: false,
    );
  }

  // Tab views for login and registration forms
  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildLoginForm(),
        _buildRegisterForm(),
      ],
    );
  }

  // Login form
  Widget _buildLoginForm() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _loginEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _loginPasswordController,
              obscureText: !_isLoginPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isLoginPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isLoginPasswordVisible = !_isLoginPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _keepMeLoggedIn,
                  onChanged: (bool? value) {
                    setState(() {
                      _keepMeLoggedIn = value ?? false;
                    });
                  },
                ),
                Text('Keep me logged in'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _loginEmailController.clear();
                    _loginPasswordController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Registration form
  Widget _buildRegisterForm() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _registerEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _registerPasswordController,
              obscureText: !_isRegisterPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isRegisterPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isRegisterPasswordVisible = !_isRegisterPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
