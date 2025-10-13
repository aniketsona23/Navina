import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../providers/speech_recognition_provider.dart';
import '../theme/app_theme.dart';

class HearingAssistScreen extends StatefulWidget {
  const HearingAssistScreen({super.key});

  @override
  State<HearingAssistScreen> createState() => _HearingAssistScreenState();
}

class _HearingAssistScreenState extends State<HearingAssistScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  bool _isInitialized = false;
  String _currentLanguage = 'English';
  final List<String> _availableLanguages = ['English', 'Spanish', 'French', 'German', 'Italian'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSpeechRecognition();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeSpeechRecognition() async {
    final provider = Provider.of<SpeechRecognitionProvider>(context, listen: false);
    await provider.initialize();
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _toggleListening() {
    final provider = Provider.of<SpeechRecognitionProvider>(context, listen: false);
    
    if (provider.isListening) {
      provider.stopListening();
      _pulseController.stop();
      _waveController.stop();
    } else {
      provider.startListening();
      _pulseController.repeat(reverse: true);
      _waveController.repeat();
    }
  }

  void _clearTranscript() {
    final provider = Provider.of<SpeechRecognitionProvider>(context, listen: false);
    provider.clearText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Hearing Assist'),
        backgroundColor: AppTheme.hearingAssistColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          // Language selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (language) {
              setState(() {
                _currentLanguage = language;
              });
            },
            itemBuilder: (context) => _availableLanguages.map((language) {
              return PopupMenuItem<String>(
                value: language,
                child: Row(
                  children: [
                    if (_currentLanguage == language)
                      const Icon(Icons.check, color: AppTheme.hearingAssistColor),
                    const SizedBox(width: 8),
                    Text(language),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: !_isInitialized
          ? _buildLoadingScreen()
          : Consumer<SpeechRecognitionProvider>(
              builder: (context, provider, child) {
                return _buildMainContent(provider);
              },
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.hearingAssistColor),
          SizedBox(height: 16),
          Text(
            'Initializing Speech Recognition...',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(SpeechRecognitionProvider provider) {
    if (!provider.isAvailable) {
      return _buildErrorScreen(provider.errorMessage ?? 'Speech recognition not available');
    }

    return Column(
      children: [
        // Status overlay
        _buildStatusOverlay(provider),
        
        // Main content area
        Expanded(
          child: _buildTranscriptArea(provider),
        ),
        
        // Control buttons
        _buildControlButtons(provider),
      ],
    );
  }

  Widget _buildStatusOverlay(SpeechRecognitionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: provider.isListening 
                    ? Colors.green.withValues(alpha: 0.8) 
                    : Colors.grey.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    provider.isListening ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.isListening ? 'Listening' : 'Ready',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Language indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _currentLanguage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptArea(SpeechRecognitionProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: provider.isListening 
              ? AppTheme.hearingAssistColor.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Transcript',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (provider.confidence > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(provider.confidence).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(provider.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Transcript content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current text (partial results)
                  if (provider.currentText.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.hearingAssistColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.hearingAssistColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        provider.currentText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Full transcript
                  if (provider.fullText.isNotEmpty)
                    Text(
                      provider.fullText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  
                  // Empty state
                  if (provider.currentText.isEmpty && provider.fullText.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic_none,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap the microphone to start listening',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(SpeechRecognitionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Clear button
          _buildModernButton(
            icon: Icons.clear_all,
            onPressed: _clearTranscript,
            tooltip: 'Clear Transcript',
          ),
          
          // Main microphone button
          _buildMainMicrophoneButton(provider),
          
          // Copy button
          _buildModernButton(
            icon: Icons.copy,
            onPressed: () {
              final provider = Provider.of<SpeechRecognitionProvider>(context, listen: false);
              final text = '${provider.fullText}${provider.currentText}';
              if (text.isNotEmpty) {
                // Copy to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Text copied to clipboard'),
                    backgroundColor: AppTheme.hearingAssistColor,
                  ),
                );
              }
            },
            tooltip: 'Copy Transcript',
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Colors.black.withValues(alpha: 0.6),
          elevation: 0,
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildMainMicrophoneButton(SpeechRecognitionProvider provider) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: provider.isListening ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: provider.isListening 
                      ? AppTheme.hearingAssistColor.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.3),
                  blurRadius: provider.isListening ? 20 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.large(
              onPressed: _toggleListening,
              backgroundColor: provider.isListening 
                  ? Colors.red 
                  : AppTheme.hearingAssistColor,
              elevation: 0,
              child: Icon(
                provider.isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Speech Recognition Error',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeSpeechRecognition,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.hearingAssistColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}