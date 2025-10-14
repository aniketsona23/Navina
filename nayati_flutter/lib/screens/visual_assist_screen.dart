import 'package:flutter/material.dart';
import 'visual_assist_screen_modern.dart';

/// Legacy wrapper for Visual Assist Screen
/// Delegates to the modern implementation
class VisualAssistScreen extends StatelessWidget {
  const VisualAssistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const VisualAssistScreenModern();
  }
}