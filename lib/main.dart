import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_shell.dart';
import 'screens/login_screen.dart';
import 'state/crm_state.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);

    return MaterialApp(
      title: 'CentraCRM Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1A1A1A),
        scaffoldBackgroundColor: const Color(0xFFF5F1EB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A1A),
          primary: const Color(0xFF1A1A1A),
          surface: Colors.white,
          background: const Color(0xFFF5F1EB),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w900,
            fontFamily: 'Outfit',
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF1A1A1A),
            fontFamily: 'Outfit',
          ),
        ),
      ),
      home: state.token == null ? const LoginScreen() : const MainShell(),
    );
  }
}
