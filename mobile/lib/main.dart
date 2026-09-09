import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/car_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

const supabaseAnonKey = 'sb_publishable_JONXidwGD6SRCgKIaPRVtA_5QgJPLB7';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CarZApp());
}

class CarZApp extends StatelessWidget {
  const CarZApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'CarZ - سوق السيارات في العراق',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        // RTL Arabic Support for Iraq
        locale: const Locale('ar', 'IQ'),
        supportedLocales: const [
          Locale('ar', 'IQ'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
