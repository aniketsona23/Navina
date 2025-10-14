import 'package:flutter/material.dart';
import '../common/index.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

/// Base class for assist screens with common functionality
abstract class AssistScreenBase extends StatefulWidget {
  final String title;
  final Color assistColor;
  final List<Widget>? appBarActions;

  const AssistScreenBase({
    super.key,
    required this.title,
    required this.assistColor,
    this.appBarActions,
  });
}

/// Base state for assist screens
abstract class AssistScreenBaseState<T extends AssistScreenBase> extends State<T>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  String? _errorMessage;

  // Getters
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  // Abstract methods to be implemented by subclasses
  Future<void> onInitialize();
  Widget buildContent(BuildContext context);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await onInitialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void setError(String? error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  void clearError() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void retry() {
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AssistScaffold(
      title: widget.title,
      assistColor: widget.assistColor,
      actions: widget.appBarActions,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized && _errorMessage == null) {
      return LoadingState(
        message: AppConstants.loadingText,
        color: widget.assistColor,
      );
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: retry,
        color: widget.assistColor,
      );
    }

    return buildContent(context);
  }
}

/// Mixin for screens with stats cards
mixin StatsCardsMixin<T extends AssistScreenBase> on AssistScreenBaseState<T> {
  Widget buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return StatCard(
      title: title,
      value: value,
      icon: icon,
      color: color,
    );
  }

  Widget buildStatsRow(List<Widget> cards) {
    return Row(
      children: cards.map((card) => Expanded(child: card)).toList(),
    );
  }
}

/// Mixin for screens with control buttons
mixin ControlButtonsMixin<T extends AssistScreenBase> on AssistScreenBaseState<T> {
  Widget buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ControlButton(
      icon: icon,
      label: label,
      onPressed: onPressed,
      color: color,
    );
  }

  Widget buildMainControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    bool isActive = false,
    double? size,
  }) {
    return Column(
      children: [
        Container(
          width: size ?? 80,
          height: size ?? 80,
          decoration: BoxDecoration(
            color: isActive ? Colors.red : color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isActive ? Colors.red : color).withValues(alpha: 0.3),
                blurRadius: isActive ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.red : color,
          ),
        ),
      ],
    );
  }
}

/// Mixin for screens with transcript display
mixin TranscriptMixin<T extends AssistScreenBase> on AssistScreenBaseState<T> {
  Widget buildTranscriptCard({
    required String currentText,
    required String fullText,
    required bool isListening,
    required double confidence,
    VoidCallback? onSpeak,
    VoidCallback? onClear,
    VoidCallback? onCopy,
  }) {
    return AppCard(
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
                  color: AppTheme.textPrimary,
                ),
              ),
              if (confidence > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(confidence).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getConfidenceColor(confidence).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.analytics,
                        size: 14,
                        color: _getConfidenceColor(confidence),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getConfidenceColor(confidence),
                        ),
                      ),
                    ],
                  ),
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
                color: isListening 
                    ? widget.assistColor.withValues(alpha: 0.3)
                    : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentText.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.assistColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.assistColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.mic,
                                size: 16,
                                color: Color(0xFFEA580C),
                              ),
                              const SizedBox(width: 8),
                              const Text(
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
                            currentText,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  if (fullText.isNotEmpty)
                    Text(
                      fullText,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  
                  if (currentText.isEmpty && fullText.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.mic_none,
                              size: 40,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tap the microphone to start listening',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (onSpeak != null || onClear != null || onCopy != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onClear != null)
                  ControlButton(
                    icon: Icons.clear_all,
                    label: 'Clear',
                    onPressed: onClear,
                    color: const Color(0xFF6B7280),
                  ),
                if (onSpeak != null)
                  ControlButton(
                    icon: Icons.volume_up,
                    label: 'Speak',
                    onPressed: onSpeak,
                    color: const Color(0xFF2563EB),
                  ),
                if (onCopy != null)
                  ControlButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onPressed: onCopy,
                    color: const Color(0xFF2563EB),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return const Color(0xFF16A34A);
    if (confidence > 0.5) return const Color(0xFFEA580C);
    return const Color(0xFFDC2626);
  }
}
