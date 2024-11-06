import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:task1/noti/firebaseApi.dart';
import 'package:task1/providers/apiProvider.dart';
import 'package:task1/providers/storageProvider.dart';
import 'package:task1/screens/bottomNavScreen.dart';
import 'package:task1/screens/homeScreen.dart';
import 'package:task1/screens/loginScreen.dart';
import 'package:task1/screens/productDetailScreen.dart';
import 'package:task1/screens/registerScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiProvider()),
        ChangeNotifierProvider(create: (_) => StorageProvider()),

      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // home: LoginScreen(),
        // home: Builder(
        //   builder: (ctx) {
        //     final user = FirebaseAuth.instance.currentUser;
        //     if(user != null){
        //       return BottomNavScreen();
        //     }
        //     else {
        //       return LoginScreen();
        //     }
        //   },
        // ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Splash Screen");
            } else if (snapshot.hasData) {

              return BottomNavScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
        routes: {
          LoginScreen.routeName: (ctx)=> LoginScreen(),
          RegisterScreen.routeName: (ctx)=> RegisterScreen(),
          HomeScreen.routeName: (ctx)=> HomeScreen(),
          ProductDetailScreen.routeName: (ctx)=> ProductDetailScreen(),
          BottomNavScreen.routeName: (ctx)=> BottomNavScreen(),
        },
        builder: EasyLoading.init(),
      ),
    );
  }
}
