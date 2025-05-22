import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../providers/user_profile_provider.dart';
import 'package:project_TUKLAS/screens/account_setup/travel_interests_page.dart';
import 'package:project_TUKLAS/screens/account_setup/travel_styles_page.dart';
import 'package:project_TUKLAS/providers/travel_plan_provider.dart';
import 'package:project_TUKLAS/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/account_setup/signup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Provider.debugCheckInvalidValueType = null;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProvider(create: (_) => TravelPlanProvider()),
        Provider<UserProfileProvider>(create: (_) => UserProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuklas',
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/': (context) => const MainScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/travel-styles') {
          final username = settings.arguments;

          return MaterialPageRoute(
            builder:
                (context) => TravelStylesPage(username: username as String),
          );
        } else if (settings.name == '/travel-interests') {
          final username = settings.arguments;

          return MaterialPageRoute(
            builder: (context) => InterestsPage(username: username as String),
          );
        }
        return null;
      },
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
