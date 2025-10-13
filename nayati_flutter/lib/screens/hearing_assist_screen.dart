import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../providers/audio_recording_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class HearingAssistScreen extends StatefulWidget {
  const HearingAssistScreen({super.key});

  @override
  State<HearingAssistScreen> createState() => _HearingAssistScreenState();
}

class _HearingAssistScreenState extends State<HearingAssistScreen> {
  final ApiService _apiService = ApiService();
  Timer? _durationTimer;
  List<Map<String, dynamic>> _transcript = [];
  bool _isProcessing = false;
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadTranscriptionHistory();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTranscriptionHistory() async {
    try {
      final history = await _apiService.getTranscriptionHistory();
      setState(() {
        _transcript = history;
      });
    } catch (e) {
      print('Failed to load transcription history: $e');
    }
  }


  Future<void> _startRecording() async {
    final provider = Provider.of<AudioRecordingProvider>(context, listen: false);
    await provider.startRecording();
  }

  Future<void> _stopRecording() async {
    final provider = Provider.of<AudioRecordingProvider>(context, listen: false);
    final path = await provider.stopRecording();
    
    if (path != null) {
      await _transcribeAudio(path);
    }
  }

  Future<void> _transcribeAudio(String audioPath) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _apiService.transcribeAudio(audioPath, language: _currentLanguage);
      
      if (result['success'] == true) {
        final newItem = {
          'speaker': 'User',
          'text': result['transcribed_text'],
          'time': DateTime.now().toString().substring(11, 19),
          'confidence': result['confidence_score'],
        };
        
        setState(() {
          _transcript.insert(0, newItem);
        });
        
        _showSnackBar('Transcription completed successfully', isError: false);
      } else {
        _showSnackBar('Transcription failed: ${result['error']}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Transcription error: $e', isError: true);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _testNetworkConnection() async {
    try {
      final result = await _apiService.testConnection();
      if (result['success'] == true) {
        _showSnackBar('API connection successful', isError: false);
      } else {
        _showSnackBar('API connection failed: ${result['error']}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Network test error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Hearing Assist'),
        backgroundColor: AppTheme.hearingAssistColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AudioRecordingProvider>(
        builder: (context, audioProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecordingControls(audioProvider),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildTranscript(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordingControls(AudioRecordingProvider audioProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.hearingAssistColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Audio Recording',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (audioProvider.isRecording)
                Text(
                  _formatDuration(audioProvider.duration),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!audioProvider.isRecording)
                _buildControlButton(
                  icon: Icons.mic,
                  label: 'Start',
                  onPressed: _startRecording,
                  color: Colors.green,
                )
              else ...[
                if (!audioProvider.isPaused)
                  _buildControlButton(
                    icon: Icons.pause,
                    label: 'Pause',
                    onPressed: () {
                      audioProvider.pauseRecording();
                    },
                    color: Colors.orange,
                  )
                else
                  _buildControlButton(
                    icon: Icons.play_arrow,
                    label: 'Resume',
                    onPressed: () {
                      audioProvider.resumeRecording();
                    },
                    color: Colors.blue,
                  ),
                _buildControlButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  onPressed: _stopRecording,
                  color: Colors.red,
                ),
              ],
            ],
          ),
          if (audioProvider.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                audioProvider.error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
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
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.history,
                label: 'History',
                onPressed: () => context.go('/history'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.wifi,
                label: 'Test API',
                onPressed: _testNetworkConnection,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.settings,
                label: 'Settings',
                onPressed: () => context.go('/settings'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppTheme.hearingAssistColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranscript() {
    return Column(
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
                color: AppTheme.textPrimary,
              ),
            ),
            if (_isProcessing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_transcript.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No transcriptions yet. Start recording to see your transcriptions here.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transcript.length,
            itemBuilder: (context, index) {
              final item = _transcript[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['speaker'] ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          item['time'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['text'] ?? '',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    if (item['confidence'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Confidence: ${(item['confidence'] * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
