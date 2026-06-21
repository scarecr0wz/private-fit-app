import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: FitFad()));
}

class FitFad extends StatelessWidget {
  const FitFad({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = AppTheme.dark;
    final themeWithInter = baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
    );

    return MaterialApp.router(
      title: 'FitFad',
      debugShowCheckedModeBanner: false,
      theme: themeWithInter,
      routerConfig: router,
    );
  }
}
