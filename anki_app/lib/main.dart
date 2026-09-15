import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/word_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnkiApp());
}

class AnkiApp extends StatelessWidget {
  const AnkiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WordProvider(),
      child: Consumer<WordProvider>(
        builder: (context, provider, child) {
          // Brand Colors
          const primaryColor = Color(0xFF002EAC);

          return MaterialApp(
            title: 'Anki Endless',
            debugShowCheckedModeBanner: false,
            themeMode: provider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,

            // Light Theme
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              fontFamily: 'Roboto',
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                primary: primaryColor,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF6F8FC),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF6F8FC),
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
            ),

            // Ultra-sleek Dark Theme
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              fontFamily: 'Roboto',
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                primary: primaryColor,
                brightness: Brightness.dark,
                surface: const Color(0xFF141923),
              ),
              scaffoldBackgroundColor: const Color(0xFF0D1117),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0D1117),
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
