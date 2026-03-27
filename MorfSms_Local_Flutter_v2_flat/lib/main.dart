import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MorfSmsLocalApp());
}

class MorfSmsLocalApp extends StatelessWidget {
  const MorfSmsLocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF3AC8FF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MorfSms Local',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08111F),
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent,
          surface: Color(0xFF0C1728),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0C1728),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF0C1728),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0B1524),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF22496F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF22496F)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
