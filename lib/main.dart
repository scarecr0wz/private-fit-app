import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router.dart';
import 'theme.dart';

import 'data/auth_service.dart';
import 'data/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Inisialisasi Riverpod Container
  final container = ProviderContainer();
  
  // Cek apakah user sudah punya token JWT aktif
  final isLoggedIn = await container.read(authServiceProvider).checkAuthStatus();

  // Jika sudah login, restore data dari VPS (berguna jika SQLite lokal baru saja diinstal / kosong)
  if (isLoggedIn) {
    await container.read(syncServiceProvider).restoreFromVpsIfEmpty();
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const FitFad(),
  ));
}

class FitFad extends ConsumerWidget {
  const FitFad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseTheme = AppTheme.dark;
    final themeWithInter = baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
    );

    return MaterialApp.router(
      title: 'FitFad',
      debugShowCheckedModeBanner: false,
      theme: themeWithInter,
      // Gunakan routerProvider dari Riverpod
      routerConfig: ref.watch(routerProvider),
    );
  }
}
