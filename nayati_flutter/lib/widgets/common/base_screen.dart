import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_scaffold.dart';
import 'app_states.dart';

/// Base screen class with common functionality
abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});
}

/// Base screen state with common functionality
abstract class BaseScreenState<T extends BaseScreen> extends State<T> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  // Abstract methods to be implemented by subclasses
  String get screenTitle;
  Color get screenColor;
  Widget buildContent(BuildContext context);
  
  // Optional methods that can be overridden
  List<Widget>? get appBarActions => null;
  Widget? get appBarLeading => null;
  bool get showBackButton => true;
  bool get centerTitle => true;
  double? get elevation => null;

  // Lifecycle methods
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await onInitialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Override this method to perform initialization
  Future<void> onInitialize() async {
    // Default implementation - can be overridden
  }

  // Helper methods
  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
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
    _initializeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return AssistScaffold(
      title: screenTitle,
      assistColor: screenColor,
      actions: appBarActions,
      leading: appBarLeading,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingState(
        message: 'Initializing...',
        color: screenColor,
      );
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: retry,
        color: screenColor,
      );
    }

    if (!_isInitialized) {
      return LoadingState(
        message: 'Loading...',
        color: screenColor,
      );
    }

    return buildContent(context);
  }
}

/// Mixin for screens that use Provider
mixin ProviderMixin<T extends BaseScreen> on BaseScreenState<T> {
  // Helper method to get provider
  R getProvider<R>() {
    return Provider.of<R>(context, listen: false);
  }

  // Helper method to watch provider
  R watchProvider<R>() {
    return Provider.of<R>(context);
  }
}

/// Mixin for screens with animations
mixin AnimationScreenMixin<T extends BaseScreen> on BaseScreenState<T> {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this as TickerProvider,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: super.buildContent(context),
    );
  }
}

/// Mixin for screens with camera functionality
mixin CameraScreenMixin<T extends BaseScreen> on BaseScreenState<T> {
  bool _isCameraInitialized = false;
  String? _cameraError;

  bool get isCameraInitialized => _isCameraInitialized;
  String? get cameraError => _cameraError;

  void setCameraInitialized(bool initialized) {
    if (mounted) {
      setState(() {
        _isCameraInitialized = initialized;
      });
    }
  }

  void setCameraError(String? error) {
    if (mounted) {
      setState(() {
        _cameraError = error;
      });
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    if (!_isCameraInitialized && _cameraError != null) {
      return ErrorState(
        message: 'Camera Error: $_cameraError',
        onRetry: retry,
        color: screenColor,
      );
    }

    return super.buildContent(context);
  }
}
