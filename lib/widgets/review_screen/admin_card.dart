import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/studio/studio_state.dart';
import '../../models/challenge/studio_challenge.dart';
import '../../theme/studio_theme.dart';
import '../../screens/challenge/create_screen.dart';
import '../glass/glass_card.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';

// Provide interface component for Admin Card.
class AdminCard extends StatelessWidget {
  final StudioChallenge challenge;

  const AdminCard({super.key, required this.challenge});

  @override
}