import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Database
import 'core/database/platform_db_helper.dart';

// Repositories
import 'data/repositories/user_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/wallet_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/waste_rate_repository.dart';
import 'data/repositories/partner_repository.dart';
import 'data/repositories/eco_flow_repository.dart';
import 'data/repositories/report_repository.dart';

// ViewModels
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/product_viewmodel.dart';
import 'viewmodel/transaction_viewmodel.dart';
import 'viewmodel/wallet_viewmodel.dart';
import 'viewmodel/cart_viewmodel.dart';
import 'viewmodel/waste_rate_viewmodel.dart';

// Views
import 'view/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize platform-specific database
  await PlatformDBHelper.initialize();

  // Desktop window configuration
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'EcoLoop Mart - Ekosistem Tukar Sampah',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories as providers (for dependency injection)
        Provider<UserRepository>(
          create: (_) => UserRepository(),
        ),
        Provider<ProductRepository>(
          create: (_) => ProductRepository(),
        ),
        Provider<TransactionRepository>(
          create: (_) => TransactionRepository(),
        ),
        Provider<WalletRepository>(
          create: (_) => WalletRepository(),
        ),
        Provider<SettingsRepository>(
          create: (_) => SettingsRepository(),
        ),
        Provider<WasteRateRepository>(
          create: (_) => WasteRateRepository(),
        ),
        Provider<PartnerRepository>(
          create: (_) => PartnerRepository(),
        ),
        Provider<EcoFlowRepository>(
          create: (context) => EcoFlowRepository(
            settingsRepository: context.read<SettingsRepository>(),
          ),
        ),
        Provider<ReportRepository>(
          create: (context) => ReportRepository(
            partnerRepository: context.read<PartnerRepository>(),
          ),
        ),

        // ViewModels
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<UserRepository>(),
          ),
        ),
        ChangeNotifierProvider<UserViewModel>(
          create: (context) => UserViewModel(
            context.read<UserRepository>(),
          ),
        ),
        ChangeNotifierProvider<ProductViewModel>(
          create: (context) => ProductViewModel(
            context.read<ProductRepository>(),
          ),
        ),
        ChangeNotifierProvider<TransactionViewModel>(
          create: (context) => TransactionViewModel(
            context.read<TransactionRepository>(),
          ),
        ),
        ChangeNotifierProvider<WalletViewModel>(
          create: (context) => WalletViewModel(
            context.read<WalletRepository>(),
          ),
        ),
        ChangeNotifierProvider<CartViewModel>(
          create: (_) => CartViewModel(),
        ),
        ChangeNotifierProvider<WasteRateViewModel>(
          create: (context) => WasteRateViewModel(
            context.read<WasteRateRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'EcoLoop Mart',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Responsive framework wrapper for all platforms
          return ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          );
        },
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D9F5D),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF0F7F4),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFF2D9F5D),
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF2D9F5D),
            foregroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Color(0xFF2D9F5D),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: const LoginPage(),
      ),
    );
  }
}
