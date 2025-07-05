import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:money_mouthy_two/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/sign_up.dart';
import 'screens/login.dart';
import 'screens/create_account.dart';
import 'screens/create_profile.dart';
import 'screens/choose_username.dart';
import 'screens/otp_verification.dart';
import 'screens/home_screen.dart';
import 'screens/create_post.dart';
import 'screens/post_feed.dart';
import 'screens/categories_ranking.dart';
import 'screens/wallet_screen.dart';
import 'screens/landing_page.dart';
import 'screens/support_page.dart';
import 'screens/privacy_policy_page.dart';
import 'screens/terms_of_service_page.dart';
import 'screens/contact_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'screens/search_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/connect_screen.dart';

void main() async {
  //hide status bar for the screen
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark, //for dark icons
    ),
  );

  //initialize firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Mouthy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/landing': (context) => const LandingPage(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/create-account': (context) => const CreateAccountScreen(),
        '/home': (context) => const HomeScreen(),
        '/create_profile': (context) => const CreateProfileScreen(),
        '/choose_username': (context) => const ChooseUsernameScreen(),
        '/otp_verification':
            (context) => const OtpVerificationScreen(email: ''),
        '/create_post': (context) => const CreatePostScreen(),
        '/post_feed': (context) => const PostFeedScreen(),
        '/categories_ranking': (context) => const CategoriesRankingScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/search': (context) => const SearchScreen(),
        '/chats': (context) => const ChatListScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/connect': (context) => const ConnectScreen(),
        '/support': (context) => const SupportPage(),
        '/privacy': (context) => const PrivacyPolicyPage(),
        '/terms': (context) => const TermsOfServicePage(),
        '/contact': (context) => const ContactPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // If user is logged in and email verified
        if (snapshot.hasData && snapshot.data!.emailVerified) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: _getUserData(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              final userData = userSnapshot.data;
              final profileCompleted = userData?['profileCompleted'] ?? false;
              final hasUsername =
                  userData?['username']?.toString().isNotEmpty ?? false;

              if (profileCompleted) {
                return const HomeScreen();
              } else if (!hasUsername) {
                return const ChooseUsernameScreen();
              } else {
                return const CreateProfileScreen();
              }
            },
          );
        }

        // User not logged in or email not verified
        if (kIsWeb) {
          return const LandingPage();
        } else {
          return const SignUpScreen();
        }
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      return doc.data();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationState();
  }

  Future<void> _checkAuthenticationState() async {
    // Wait for Firebase to initialize and check auth state
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      // User is logged in and email is verified
      try {
        // Check if profile is completed
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 10));

        final userData = userDoc.data();
        final profileCompleted = userData?['profileCompleted'] ?? false;
        final hasUsername =
            userData?['username']?.toString().isNotEmpty ?? false;

        if (!mounted) return;

        if (profileCompleted) {
          // Profile is complete, go to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (!hasUsername) {
          // Need to choose username
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ChooseUsernameScreen(),
            ),
          );
        } else {
          // Need to complete profile
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const CreateProfileScreen(),
            ),
          );
        }
      } catch (e) {
        // Error checking profile, go to home anyway since user is authenticated
        debugPrint('Error checking profile completion: $e');
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // User is not logged in or email not verified
      if (kIsWeb) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LandingPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/money_mouth.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // App Name
            const Text(
              'Money Mouthy',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            // Tagline
            const Text(
              'Put Yo Money Where Yo Mouth is!',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
