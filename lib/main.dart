import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Importe suas rotas
import 'routes/login.dart';
import 'routes/register.dart';
import 'routes/home.dart';
import 'routes/root.dart';
import 'routes/profile.dart';
import 'routes/user_cupons.dart';

import './viewmodel/cupon.dart';
import './viewmodel/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Usa o MultiProvider para fornecer múltiplos ViewModels
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => CouponViewModel()),
      ],
      child: MaterialApp(
        title: "Recicla+",
        initialRoute: "/",
        debugShowCheckedModeBanner: false,
        routes: {
          "/": (context) => RootScreen(),
          "/login": (context) => LoginScreen(),
          "/register": (context) => RegisterScreen(),
          "/home": (context) => HomeScreen(),
          "/profile": (context) => UserProfileScreen(),
          "/user-cupons": (context) => UserPurchasedCouponsPage(),
        },
      ),
    );
  }
}
