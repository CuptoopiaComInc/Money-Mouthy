import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_mouthy_two/firebase_options.dart';
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
import 'services/wallet_service.dart';
import 'services/post_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
      //hide status bar for the screen
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark //for dark icons
    ));

    //initialize firebase 
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize services
    await WalletService().initialize();
    await PostService().initialize();

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
      home: const SplashScreen(),
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/create-account': (context) => const CreateAccountScreen(),
        '/home': (context) => const HomeScreen(),
        '/create_profile': (context) => const CreateProfileScreen(),
        '/choose_username': (context) => const ChooseUsernameScreen(),
        '/otp_verification': (context) => const OtpVerificationScreen(email: ''),
        '/create_post': (context) => const CreatePostScreen(),
        '/post_feed': (context) => const PostFeedScreen(),
        '/categories_ranking': (context) => const CategoriesRankingScreen(),
        '/wallet': (context) => const WalletScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{
  @override
  void initState() {
    super.initState();
    // navigate to home screen after delete
    Future.delayed(const Duration(seconds: 3), (){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Money Mouth Logo - Using a placeholder until the image issue is resolved
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
              'Put Yo Money Where Yo Muuth is!',
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
