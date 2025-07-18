import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether/services/theme_service.dart';
import 'package:aether/services/settings_service.dart';
import 'package:aether/services/navigation_service.dart';
import 'package:aether/repositories/content_repository.dart';
import 'package:aether/router.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final themeService = ThemeService();
  await themeService.initialize();
  
  final settingsService = SettingsService();
  await settingsService.initialize();
  
  final navigationService = NavigationService();
  
  // Initialize repository
  final contentRepository = ContentRepository();
  
  // Initialize router
  final appRouter = AppRouter(
    contentRepository: contentRepository,
    navigationService: navigationService,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>.value(value: themeService),
        Provider<SettingsService>.value(value: settingsService),
        Provider<NavigationService>.value(value: navigationService),
        Provider<ContentRepository>.value(value: contentRepository),
      ],
      child: AetherApp(router: appRouter),
    ),
  );
}

class AetherApp extends StatelessWidget {
  final AppRouter router;
  
  const AetherApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return MaterialApp.router(
      title: 'Aether',
      theme: themeService.getLightTheme(),
      darkTheme: themeService.getDarkTheme(),
      themeMode: themeService.themeMode,
      routerConfig: router.router,
    );
  }
}

