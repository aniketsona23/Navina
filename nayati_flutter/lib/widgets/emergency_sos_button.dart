import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/emergency_service.dart';
import '../utils/logger_util.dart';

class EmergencySOSButton extends StatefulWidget {
  final bool isFloating;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;

  const EmergencySOSButton({
    super.key,
    this.isFloating = true,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.size,
  });

  @override
  State<EmergencySOSButton> createState() => _EmergencySOSButtonState();
}

class _EmergencySOSButtonState extends State<EmergencySOSButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Pulse animation for attention-grabbing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Shake animation when pressed
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));

    // Start pulsing animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handlePress() async {
    if (_isPressed) return;

    setState(() => _isPressed = true);

    // Provide immediate haptic feedback
    await HapticFeedback.heavyImpact();

    // Trigger shake animation
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });

    // Call custom onPressed or show emergency menu
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      _showEmergencyMenu();
    }

    // Reset pressed state after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isPressed = false);
      }
    });
  }

  void _showEmergencyMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEmergencyMenu(),
    );
  }

  Widget _buildEmergencyMenu() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.emergency,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Emergency SOS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your emergency action',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Emergency actions
          ...EmergencyService.getEmergencyActions().map(
            (action) => _buildEmergencyActionTile(action),
          ),

          // Cancel button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyActionTile(EmergencyAction action) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            action.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
      title: Text(
        action.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        action.subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        Navigator.pop(context);
        _handleEmergencyAction(action);
      },
    );
  }

  Future<void> _handleEmergencyAction(EmergencyAction action) async {
    try {
      bool success = false;

      switch (action.action) {
        case EmergencyActionType.call:
          success = await EmergencyService.callEmergency();
          break;
        case EmergencyActionType.sms:
          success = await EmergencyService.sendEmergencySMS(
              'EMERGENCY SOS - I need help immediately!');
          break;
        case EmergencyActionType.smsWithLocation:
          success = await EmergencyService.sendEmergencySMSWithLocation();
          break;
        case EmergencyActionType.contacts:
          // Guard context usage after async gap
          if (!mounted) return;
          _showEmergencyContacts();
          return;
      }

      if (!mounted) return; // Ensure widget still in tree before using context
      if (success) {
        _showSuccessMessage(action.title);
      } else {
        _showErrorMessage(action.title);
      }
    } catch (e) {
      EmergencyLogger.error('Emergency action failed: $e');
      if (mounted) {
        _showErrorMessage(action.title);
      }
    }
  }

  void _showEmergencyContacts() {
    EmergencyService.showEmergencyContactsDialog(context);
  }

  void _showSuccessMessage(String action) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action initiated successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String action) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to initiate $action. Please try again.'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _handleEmergencyAction(
            EmergencyService.getEmergencyActions().firstWhere(
              (a) => a.title == action,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? (widget.isFloating ? 80.0 : 60.0);
    final backgroundColor = widget.backgroundColor ?? Colors.red;
    final textColor = widget.textColor ?? Colors.white;

    if (widget.isFloating) {
      return AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _shakeAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _shakeAnimation.value * (10 * (1 - _shakeAnimation.value)),
              0,
            ),
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: FloatingActionButton(
                onPressed: _handlePress,
                backgroundColor: backgroundColor,
                child: _buildButtonContent(size, textColor),
              ),
            ),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _shakeAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * (10 * (1 - _shakeAnimation.value)),
            0,
          ),
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: GestureDetector(
              onTap: _handlePress,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _buildButtonContent(size, textColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(double size, Color textColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.emergency,
          color: textColor,
          size: size * 0.4,
        ),
        Text(
          'SOS',
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

/// Static helper method for handling emergency actions
Future<void> _handleEmergencyActionAsync(
    BuildContext context, EmergencyAction action) async {
  // Capture messenger up front to avoid using BuildContext after async gaps
  final messenger = ScaffoldMessenger.maybeOf(context);
  bool success = false;

  switch (action.action) {
    case EmergencyActionType.call:
      success = await EmergencyService.callEmergency();
      break;
    case EmergencyActionType.sms:
      success = await EmergencyService.sendEmergencySMS(
          'EMERGENCY SOS - I need help immediately!');
      break;
    case EmergencyActionType.smsWithLocation:
      success = await EmergencyService.sendEmergencySMSWithLocation();
      break;
    case EmergencyActionType.contacts:
      EmergencyService.showEmergencyContactsDialog(context);
      return;
  }

  // Show result without using context post-awaits
  if (success) {
    if (messenger != null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Action initiated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      AppLogger.info('${action.title} initiated successfully');
    }
  } else {
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to initiate ${action.title}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      AppLogger.error('Failed to initiate ${action.title}');
    }
  }
}

/// Inline SOS button for app bars and inline use
class InlineSOSButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const InlineSOSButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ??
          () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => _buildEmergencyMenu(context),
            );
          },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.emergency,
          color: Colors.white,
          size: 20,
        ),
      ),
      tooltip: 'Emergency SOS',
    );
  }

  Widget _buildEmergencyMenu(BuildContext context) {
    // Same emergency menu as in EmergencySOSButton
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.emergency,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Emergency SOS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your emergency action',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ...EmergencyService.getEmergencyActions().map(
            (action) => ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    action.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              title: Text(
                action.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                action.subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.pop(context);
                _handleEmergencyActionAsync(context, action);
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
