import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../providers/speech_recognition_provider.dart';
import '../providers/text_to_speech_provider.dart';

class HearingAssistScreenModern extends StatefulWidget {
  const HearingAssistScreenModern({super.key});

  @override
  State<HearingAssistScreenModern> createState() => _HearingAssistScreenModernState();
}

class _HearingAssistScreenModernState extends State<HearingAssistScreenModern> with TickerProviderStateMixin {
  static const String _defaultLanguage = 'English';
  static const List<String> _availableLanguages = ['English', 'Spanish', 'French', 'German', 'Italian'];
  static const Duration _pulseDuration = Duration(milliseconds: 1500);
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isInitialized = false;
  String _currentLanguage = _defaultLanguage;
  final TextEditingController _textInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSpeechRecognition();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textInputController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: _pulseDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeSpeechRecognition() async {
    final speechProvider = Provider.of<SpeechRecognitionProvider>(context, listen: false);
    final ttsProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    
    await Future.wait([
      speechProvider.initialize(),
      ttsProvider.initialize(),
    ]);
    
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
    } else {
      provider.startListening();
      _pulseController.repeat(reverse: true);
    }
  }

  void _clearTranscript() {
    final provider = Provider.of<SpeechRecognitionProvider>(context, listen: false);
    provider.clearText();
  }

  void _speakTranscript() {
    final speechProvider = Provider.of<SpeechRecognitionProvider>(context, listen: false);
    final ttsProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    
    final textToSpeak = speechProvider.fullText.isNotEmpty 
        ? speechProvider.fullText 
        : speechProvider.currentText;
    
    if (textToSpeak.isNotEmpty) {
      ttsProvider.speak(textToSpeak);
    }
  }

  void _speakTypedText() {
    final ttsProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    final text = _textInputController.text.trim();
    
    if (text.isNotEmpty) {
      ttsProvider.speak(text);
    }
  }

  void _stopSpeaking() {
    final ttsProvider = Provider.of<TextToSpeechProvider>(context, listen: false);
    ttsProvider.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Hearing Assist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEA580C),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
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
            icon: const Icon(Icons.language, size: 24),
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
                      const Icon(Icons.check, color: Color(0xFFEA580C)),
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
          : Consumer2<SpeechRecognitionProvider, TextToSpeechProvider>(
              builder: (context, speechProvider, ttsProvider, child) {
                if (!speechProvider.isAvailable) {
                  return _buildErrorScreen(speechProvider.errorMessage ?? 'Speech recognition not available');
                }
                return _buildMainContent(speechProvider, ttsProvider);
              },
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFEA580C),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Initializing Speech Recognition...',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(SpeechRecognitionProvider speechProvider, TextToSpeechProvider ttsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(speechProvider, ttsProvider),
          const SizedBox(height: 20),
          _buildTranscriptCard(speechProvider, ttsProvider),
          const SizedBox(height: 20),
          _buildTextToSpeechCard(ttsProvider),
          const SizedBox(height: 20),
          _buildControlButtons(speechProvider, ttsProvider),
        ],
      ),
    );
  }

  Widget _buildStatsCards(SpeechRecognitionProvider speechProvider, TextToSpeechProvider ttsProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Listening',
                speechProvider.isListening ? 'Active' : 'Ready',
                speechProvider.isListening ? Icons.mic : Icons.mic_off,
                speechProvider.isListening ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Speaking',
                ttsProvider.isSpeaking 
                    ? (ttsProvider.isPaused ? 'Paused' : 'Active')
                    : 'Ready',
                ttsProvider.isSpeaking ? Icons.volume_up : Icons.volume_off,
                ttsProvider.isSpeaking ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Confidence',
                speechProvider.confidence > 0 ? '${(speechProvider.confidence * 100).toStringAsFixed(0)}%' : '0%',
                Icons.analytics,
                _getConfidenceColor(speechProvider.confidence),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Language',
                _currentLanguage,
                Icons.language,
                const Color(0xFFEA580C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptCard(SpeechRecognitionProvider speechProvider, TextToSpeechProvider ttsProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Transcript',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              Row(
                children: [
                  if (speechProvider.confidence > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(speechProvider.confidence).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getConfidenceColor(speechProvider.confidence).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.analytics,
                            size: 14,
                            color: _getConfidenceColor(speechProvider.confidence),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(speechProvider.confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getConfidenceColor(speechProvider.confidence),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  // TTS controls for transcript
                  if (speechProvider.fullText.isNotEmpty || speechProvider.currentText.isNotEmpty)
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (ttsProvider.isSpeaking) {
                              _stopSpeaking();
                            } else {
                              _speakTranscript();
                            }
                          },
                          icon: Icon(
                            ttsProvider.isSpeaking ? Icons.stop : Icons.volume_up,
                            color: const Color(0xFF2563EB),
                            size: 20,
                          ),
                          tooltip: ttsProvider.isSpeaking ? 'Stop Speaking' : 'Speak Transcript',
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: speechProvider.isListening 
                  ? const Color(0xFFEA580C).withValues(alpha: 0.3)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current text (partial results)
                  if (speechProvider.currentText.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFEA580C).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.mic,
                                size: 16,
                                color: Color(0xFFEA580C),
                              ),
                              SizedBox(width: 8),
                          Text(
                            'Live transcription...',
                            style: TextStyle(
                              color: Color(0xFFEA580C),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            speechProvider.currentText,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Full transcript
                  if (speechProvider.fullText.isNotEmpty)
                    Text(
                      speechProvider.fullText,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  
                  // Empty state
                  if (speechProvider.currentText.isEmpty && speechProvider.fullText.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.mic_none,
                              size: 32,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tap the microphone to start listening',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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

  Widget _buildTextToSpeechCard(TextToSpeechProvider ttsProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Text to Speech',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              if (ttsProvider.isSpeaking)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.volume_up,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ttsProvider.isPaused ? 'Paused' : 'Speaking',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textInputController,
            maxLines: 3,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Type text to speak...',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2563EB)),
              ),
              contentPadding: const EdgeInsets.all(16),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_textInputController.text.trim().isNotEmpty) {
                      _speakTypedText();
                    }
                  },
                  icon: Icon(
                    ttsProvider.isSpeaking ? Icons.stop : Icons.volume_up,
                    size: 20,
                  ),
                  label: Text(
                    ttsProvider.isSpeaking ? 'Stop' : 'Speak',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (ttsProvider.isSpeaking)
                IconButton(
                  onPressed: ttsProvider.isPaused ? ttsProvider.resume : ttsProvider.pause,
                  icon: Icon(
                    ttsProvider.isPaused ? Icons.play_arrow : Icons.pause,
                    color: const Color(0xFF2563EB),
                  ),
                  tooltip: ttsProvider.isPaused ? 'Resume' : 'Pause',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(SpeechRecognitionProvider speechProvider, TextToSpeechProvider ttsProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.clear_all,
                label: 'Clear',
                onPressed: _clearTranscript,
                color: const Color(0xFF6B7280),
              ),
              _buildMainMicrophoneButton(speechProvider),
              _buildControlButton(
                icon: Icons.copy,
                label: 'Copy',
                onPressed: () {
                  final text = '${speechProvider.fullText}${speechProvider.currentText}';
                  if (text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text copied to clipboard'),
                        backgroundColor: Color(0xFFEA580C),
                      ),
                    );
                  }
                },
                color: const Color(0xFF2563EB),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 24),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMainMicrophoneButton(SpeechRecognitionProvider speechProvider) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: speechProvider.isListening ? _pulseAnimation.value : 1.0,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: speechProvider.isListening 
                      ? Colors.red 
                      : const Color(0xFFEA580C),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: speechProvider.isListening 
                          ? Colors.red.withValues(alpha: 0.3)
                          : const Color(0xFFEA580C).withValues(alpha: 0.3),
                      blurRadius: speechProvider.isListening ? 20 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    speechProvider.isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _toggleListening,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                speechProvider.isListening ? 'Stop' : 'Listen',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: speechProvider.isListening ? Colors.red : const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF16A34A);
    if (confidence >= 0.6) return const Color(0xFFEA580C);
    return const Color(0xFFEF4444);
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Speech Recognition Error',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeSpeechRecognition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
