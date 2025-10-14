import 'package:flutter/material.dart';
import 'hearing_assist_screen_modern.dart';

/// Legacy wrapper for Hearing Assist Screen
/// Delegates to the modern implementation
class HearingAssistScreen extends StatelessWidget {
  const HearingAssistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HearingAssistScreenModern();
  }
}