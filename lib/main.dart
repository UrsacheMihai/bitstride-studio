import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'studio_theme.dart';
import 'providers/studio_state.dart';
import 'screens/studio_auth_screen.dart';
import 'screens/studio_home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StudioApp());
}

class StudioApp extends StatelessWidget {
  const StudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudioState()..initialize(),
      child: Builder(builder: (context) {
        return Consumer<StudioState>(
          builder: (_, state, __) {
            return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale(state.language),
              title: 'BitStride Studio',
              debugShowCheckedModeBanner: false,
              theme: StudioTheme.lightTheme(),
              darkTheme: StudioTheme.darkTheme(),
              themeMode: ThemeMode.system,
              home: state.isLoading
                  ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                  : state.isAuthenticated
                      ? const StudioHome()
                      : const StudioAuthScreen(),
            );
          },
        );
      }),
    );
  }
}
