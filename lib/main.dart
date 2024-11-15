import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'auth_page.dart';
import 'home_page.dart';
import 'spice_chat.dart';
import 'message_provider.dart';
import 'auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()), // Provide AuthProvider
        ChangeNotifierProvider(create: (context) => MessageProvider()), // Provide MessageProvider
      ],
      child: MaterialApp(
        title: 'Recipe Riot',
        theme: ThemeData(
          primarySwatch: Colors.red,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.red,
          ),
        ),
        initialRoute: '/auth',
        routes: {
          '/auth': (context) => AuthPage(), // Route to AuthPage for login and registration
          '/home': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?; // Retrieve arguments
            final username = args?['username'] ?? 'User'; // Get username or use default
            return HomePage(username: username);
          },
          '/chat': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?; // Retrieve arguments
            final receiverId = args?['receiverId'] ?? 'Unknown'; // Get receiver ID or use default
            return SpiceChat(receiverId: receiverId); // Pass receiverId to SpiceChat
          },
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => AuthPage(), // Redirect to AuthPage for unknown routes
          );
        },
      ),
    );
  }
}
