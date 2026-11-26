import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/reminder_service.dart';

// Kasane Teto inspired colors
const tetoRed = Color(0xFFC62845);
const tetoPink = Color(0xFFF28C9F);
const tetoLightPink = Color(0xFFFFD9DF);
const tetoBackground = Color(0xFFFFF3F5);
const tetoCharcoal = Color(0xFF37333A);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initReminders();
  runApp(const MemoryCardsApp());
}

class MemoryCardsApp extends StatelessWidget {
  const MemoryCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Cards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: tetoRed,
          brightness: Brightness.light,
        ).copyWith(
          primary: tetoRed,
          onPrimary: Colors.white,
          secondary: tetoCharcoal,
          onSecondary: Colors.white,
          surface: tetoBackground,
          onSurface: tetoCharcoal,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: tetoBackground,
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            side: BorderSide(color: tetoPink, width: 1.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: tetoLightPink,
          foregroundColor: tetoCharcoal,
          shape: Border(
            bottom: BorderSide(color: tetoRed, width: 3),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: tetoRed,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}