import 'package:chat_bot/common/helper/theme_provider.dart';
import 'package:chat_bot/core/config/app_theme.dart';

import 'package:chat_bot/presentation/welecom/welecom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: themeProvider.themeMode, // ✅ Use dynamic theme
          debugShowCheckedModeBanner: false,
          home: const WelecomPage(),
        );
      },
    );
  }
}
