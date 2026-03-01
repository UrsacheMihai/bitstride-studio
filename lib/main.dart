import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import './config/firebase_options.dart';
import './theme/studio_theme.dart';
import './providers/studio/studio_state.dart';
import './screens/auth/studio_auth_screen.dart';
import './screens/home/studio_home.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';

// Initialize Firebase and start the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StudioApp());
}

// Define the data structure and initialize the Studio App.
class StudioApp extends StatelessWidget {
  const StudioApp({super.key});

  @override
}