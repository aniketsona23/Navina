import 'package:flutter/material.dart';

/// Mixin for common animation functionality
mixin AnimationMixin<T extends StatefulWidget> on State<T> {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Animation constants
  static const Duration _pulseDuration = Duration(milliseconds: 1500);
  static const Duration _fadeDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Pulse animation
    _pulseController = AnimationController(
      duration: _pulseDuration,
      vsync: this as TickerProvider,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Fade animation
    _fadeController = AnimationController(
      duration: _fadeDuration,
      vsync: this as TickerProvider,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  /// Start pulse animation
  void startPulse() {
    _pulseController.repeat(reverse: true);
  }

  /// Stop pulse animation
  void stopPulse() {
    _pulseController.stop();
  }

  /// Start fade in animation
  void startFadeIn() {
    _fadeController.forward();
  }

  /// Start fade out animation
  void startFadeOut() {
    _fadeController.reverse();
  }

  /// Get pulse animation
  Animation<double> get pulseAnimation => _pulseAnimation;

  /// Get fade animation
  Animation<double> get fadeAnimation => _fadeAnimation;

  /// Check if pulse is animating
  bool get isPulsing => _pulseController.isAnimating;

  /// Check if fade is animating
  bool get isFading => _fadeController.isAnimating;
}

/// Animated button with pulse effect
class AnimatedPulseButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isAnimating;
  final Duration duration;

  const AnimatedPulseButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isAnimating = false,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedPulseButton> createState() => _AnimatedPulseButtonState();
}

class _AnimatedPulseButtonState extends State<AnimatedPulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedPulseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isAnimating && oldWidget.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isAnimating ? _animation.value : 1.0,
          child: widget.child,
        );
      },
    );
  }
}

/// Fade transition widget
class FadeTransitionWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool isVisible;

  const FadeTransitionWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.isVisible = true,
  });

  @override
  State<FadeTransitionWidget> createState() => _FadeTransitionWidgetState();
}

class _FadeTransitionWidgetState extends State<FadeTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FadeTransitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
