import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'studio_theme.dart';
import 'providers/studio_state.dart';
import 'screens/studio_auth_screen.dart';
import 'screens/studio_home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';
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
                  ? Scaffold(
                      body: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0D1117), Color(0xFF161B22)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: StudioTheme.creatorGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: StudioTheme.accentPurple
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.code_rounded,
                                    color: Colors.white, size: 40),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'BitStride Studio',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: StudioTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
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

